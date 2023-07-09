def base(config, vmhost, reboot_after_up: true)

    os = HOSTS[vmhost][:os]
    arch = HOSTS[vmhost][:arch]

    if os == "mac" && arch == "arm64"
        config.vm.box = "starboard/ubuntu-arm64-20.04.5"
        config.vm.box_version = "20221120.20.40.0"
    else
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.box_version = "202112.19.0"
    end

    config.vm.provider :vmware_desktop do |v|
        v.ssh_info_public = true
        v.gui = true
        v.vmx["ethernet0.virtualdev"] = "vmxnet3"
        v.vmx["ethernet0.connectiontype"] = "bridged"
    end

    config.vm.provision "pre-install", type: "shell", reboot: reboot_after_up, inline: <<~SCRIPT
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y avahi-daemon

        # Permanently disable swap
        swapoff -a
        sed 's|/swap|#/swap|g' -i /etc/fstab

        # Workaround for "sticky" DHCP IPs
        # https://kb.vmware.com/s/article/82229
        # A reboot is required so the DHCP server can give this VM a new unique IP, which will
        # also be given to Vagrant
        echo -n > /etc/machine-id
        rm /var/lib/dbus/machine-id
        ln -s /etc/machine-id /var/lib/dbus/machine-id
    SCRIPT
end