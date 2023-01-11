require 'socket'
require_relative 'node-base.rb'

def dns(config, vmhost:, name:, macaddr:)
    return if Socket.gethostname != vmhost

    config.vm.define name do |node|
        base(config, vmhost, reboot_after_up: false)
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "1"
            v.vmx["memsize"] = "512"
            v.vmx["ethernet0.addressType"] = "static"
            v.vmx["ethernet0.address"] = macaddr
        end

        node.vm.provision "install", type: "shell", inline: <<~SCRIPT
            export DEBIAN_FRONTEND=noninteractive

            apt-get install -y dnsmasq

            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            echo "If dnsmasq failed during installation with this error message:"
            echo "    failed to create listening socket for port 53: Address already in use"
            echo "Ignore it."
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

            systemctl disable systemd-resolved
            systemctl stop systemd-resolved
            systemctl enable dnsmasq
            systemctl restart dnsmasq
        SCRIPT

        node.vm.provision "reload", after: "install", type: "shell", run: "never", inline: <<~SCRIPT
            cp /vagrant/etc/dnsmasq.conf /etc/dnsmasq.conf
            systemctl restart dnsmasq
        SCRIPT
    end
end

