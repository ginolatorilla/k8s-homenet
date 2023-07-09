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
            /vagrant/scripts/install-base.sh

            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            echo "If dnsmasq fails to start during installation, ignore it."
            echo "We will have to stop systemd-resolved after (we can't stop if before"
            echo "because we need to resolve Ubuntu servers)."
            echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
            apt-get install -y dnsmasq
            
            systemctl disable systemd-resolved
            systemctl stop systemd-resolved
            systemctl enable dnsmasq
            systemctl restart dnsmasq
        SCRIPT

        node.vm.provision "reload", after: "install", type: "shell", inline: <<-SCRIPT
            cp /vagrant/etc/dnsmasq.conf /etc/dnsmasq.conf
            systemctl restart dnsmasq
        SCRIPT
    end
end

