# Kubernetes Cluster in my Home Network

## Installation

The following assumes that the router has the following properties:

- Built-in DHCP server
- DHCP server address pool range is from 192.168.0.2 to 192.168.0.249
- Router's LAN subnet is 255.255.255.0
- Router's default gateway is 192.168.0.1

In the router's DHCP server settings, reserve these IPs.

| Node                          | MAC address       | IP address reservation |
| ----------------------------- | ----------------- | ---------------------- |
| vh0-mac-vm-ub20-dns0          | 00:0C:29:93:79:0E | 192.168.0.53           |

The MAC addresses may be found in the Vagrantfile where the node/vm is defined.

In the router's DHCP server settings, set the DNS servers.

| Property      | Value                         |
| ------------- | ----------------------------- |
| Primary DNS   | 192.168.0.53                  |
| Secondary DNS | _Same as the Default Gateway_ |

Generate custom certificate authority.

```sh
scripts/generate-custom-ca.sh
scripts/renew-ingress-certs.sh
```

Install VMWare Fusion/Player and VMWare Utility for Vagrant.

```sh
brew install hashicorp/tap/hashicorp-vagrant
brew install qemu
vagrant plugin install vagrant-vmware-desktop
scripts/generate-custom-ca.sh # Run this command once, or else you have to upload all new certificates

vagrant up
vagrant reload --provision-with reload [VM_NAME]

# For any subsequent reconfiguration that does not require VM reboot:
vagrant provision --provision-with reload [VM_NAME]

# Bootstrap the cluster
kustomize build | kubectl apply -f-
```

Add this file to `/etc/resolver/homenet`

```text
domain homenet
nameserver 192.168.0.53
search_order 1
timeout 5
```

Add these lines to `/etc/resolv.conf`. If you have a VPN client, you have to replace this file.

```text
nameserver 192.168.0.53
nameserver 192.168.0.1
nameserver 127.0.0.1
```

## Topology

```plaintext
Router
 Host 1: MacOS (32GB/10CPU)
  Node: Control 1
  Node: Infra 1
  Node: Worker 1
  Node: Worker 2
  Node: Worker 3
 Host 2: Windows 10 (8GB/4CPU)
  Node: Control 2
  Node: Infra 2
  Node: Worker 4
 Host 3: Windows 11 (16GB/8CPU)
  Node: Control 3
  Node: Worker 5
  Node: Worker 6
```

## Limitations

- The number of VMs that you can spawn is limited by your host resources and the router's DHCP subnet address range.
- Multiple VMs defined in the Vagrant file will always be assigned by DHCP the same IP, because VMWare will clone
  the base images (Ubuntu 20.04) especially the value in `/etc/machine-id`. Higher versions of Ubuntu use machine ids
  when requesting for IPs with DHCP, so you must reacquire the unique machine ids for every new VM.
- Vagrant unmounts all shared drives (eg the default `/vagrant` share in the VMs) when shell provisioners have
  `reboot: true` set. Any subsequent `vagrant provision` call will fail unless you run `vagrant reboot`. For example,
  the machine id workaround needs a reboot so the VM can pick up a new IP and relay it to Vagrant.
- Provisioning network interfaces with Vagrant is inconsistent, so they must be configured in the VMX key/value pairs.
- `dnsmasq` cannot have address records pointing to domains (eg vm.local), so VMs that will require domains must have
  fixed IPs. This can be achieved in VMX by setting `address=<static-mac-address>` and `addressType=static`, and then
  configuring the router to reserve an IP for that MAC address.

### Specific to macOS with Apple Silicon

The following applies to macOS 12 "Monterey" with Apple Silicon M1.

- VirtualBox doesn't work so the default provisioner must be VMWare (ie VMWare Fusion).
- Vagrant needs to launch VMs with GUI.

## Troubleshooting

### "Could not resolve api.k8s.homenet"

- Ensure that the router's DHCP primary DNS setting is set to the static IP of the DNS VM.
- Ensure that the DNS VM is running and that `dnsmasq` is serving at port 53.
- MacOS host: If you have VPN running, every time you connect/disconnect, you have to modify `/etc/resolv.conf`
- Ubuntu VM: Run `resolvectl status` and check the Current DNS Server. If it's incorrect, run
  `sudo systemctl restart systemd-resolved` to reset the primary DNS from the router's DHCP server.

### Error message during dnsmasq installation: "failed to create listening socket for port 53: Address already in use"

Ignore it. Port 53 is currently taken by `systemd-resolved`, and you cannot deactivate it otherwise `apt` cannot
resolve addresses from the internet properly.

### HAProxy service fails with "Start request repeated too quickly"

Run `haproxy -c -f /etc/haproxy/haproxy.cfg` to check if there are any errors in the config file, and then restart.

### After `vagrant resume`, IP of guest VMs could not be detected

If Vagrant complains that it could not get the IPs after resuming suspended VMs, simply re-run `vagrant resume` or
resume them from VMWare Fusion.

### After `vagrant resume`, IPs are assigned host-only (eg 172.X.X.X)

It appears that the VM will be using host-only networks, but eventually it will revert back to bridged-mode and
re-acquire proper IPs from the router's DHCP. You can verify this by inspecting the VMs in VMWare after Vagrant
finishes resuming them.

### After `vagrant resume`, the VM's IPs could not be detected

If you see the error message "The IP of the guest VM could not be detected", try running `vagrant ssh` on the errant
VM. The error message provides recommendations should the VM become unreachable.
