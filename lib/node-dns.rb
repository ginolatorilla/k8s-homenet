require 'socket'
require_relative 'node-base.rb'

def dns(config, vmhost:, name:, macaddr:)
    return if Socket.gethostname != vmhost

    base(config, vmhost)

    config.vm.define name do |node|
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "1"
            v.vmx["memsize"] = "512"
            v.vmx["ethernet0.addressType"] = "static"
            v.vmx["ethernet0.address"] = macaddr
        end

        node.vm.provision "install", type: "shell", inline: <<-SCRIPT
            export DEBIAN_FRONTEND=noninteractive
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            echo "If dnsmasq fails to start during installation, ignore it."
            echo "We will have to stop systemd-resolved after (we can't stop if before"
            echo "because we need to resolve Ubuntu servers)."
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            apt-get update
            apt-get install -y dnsmasq avahi-daemon
            
            systemctl disable systemd-resolved
            systemctl stop systemd-resolved
            systemctl enable dnsmasq
            systemctl restart dnsmasq
        SCRIPT

        node.vm.provision "configure", type: "file", source: "./etc", destination: "/tmp/etc"

        node.vm.provision "reload", after: "configure", type: "shell", inline: <<-SCRIPT
            mv /tmp/etc/dnsmasq.conf /etc/dnsmasq.conf
            systemctl restart dnsmasq
        SCRIPT
    end
end

