require 'socket'
require_relative 'node-base.rb'

def infra(config, vmhost:, name:, macaddr:)
    return if Socket.gethostname != vmhost

    base(config, vmhost)

    config.vm.define name do |node|
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "1"
            v.vmx["memsize"] = "1024"
            v.vmx["ethernet0.addressType"] = "static"
            v.vmx["ethernet0.address"] = macaddr
        end

        node.vm.provision "install", type: "shell", inline: <<-SCRIPT
            /vagrant/scripts/install-base.sh
            apt-get install -y haproxy
        SCRIPT

        node.vm.provision "reload", after: "install", type: "shell", inline: <<-SCRIPT
            cp /vagrant/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
            systemctl reload haproxy
        SCRIPT
    end
end

