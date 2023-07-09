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
| host0-darwin-aarch64-dns      | 00:0C:29:69:2A:FB | 192.168.0.200          |
| host0-darwin-aarch64-infra-0  | 00:0C:29:69:2A:FB | 192.168.0.201          |
| host0-darwin-aarch64-master-0 | 00:0C:29:93:79:0E | 192.168.0.202          |

The MAC addresses may be found in the Vagrantfile where the node/vm is defined.

In the router's DHCP server settings, set the DNS servers.

| Property      | Value                         |
| ------------- | ----------------------------- |
| Primary DNS   | 192.168.0.200                 |
| Secondary DNS | _Same as the Default Gateway_ |

Install VMWare Fusion/Player and VMWare Utility for Vagrant.

```sh
brew install hashicorp/tap/hashicorp-vagrant
brew install qemu
vagrant plugin install vagrant-vmware-desktop
vagrant up
```

Add this file to `/etc/resolver/net`

```text
domain net
nameserver 192.168.0.200
search_order 1
timeout 5
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
