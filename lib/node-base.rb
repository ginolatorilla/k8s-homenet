def base(config, vmhost)

    os = HOSTS[vmhost][:os]
    arch = HOSTS[vmhost][:arch]

    if os == "mac" && arch == "arm64"
        config.vm.box = "starboard/ubuntu-arm64-20.04.5"
        config.vm.box_version = "20221120.20.40.0"
    else
        config.vm.box = "bento/ubuntu-20.04"
        config.vm.box_version = "202112.19.0"
    end

    config.vm.provider :vmware_desktop do |v, override|
        v.ssh_info_public = true
        v.gui = true
        v.vmx["ethernet0.virtualdev"] = "vmxnet3"
        v.vmx["ethernet0.connectiontype"] = "bridged"
    end

end