require 'socket'
require_relative 'node-base.rb'

def infra(config, vmhost:, name:, macaddr:)
    return if Socket.gethostname != vmhost

    config.vm.define name do |node|
        base(node, vmhost)
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "1"
            v.vmx["memsize"] = "1024"
            v.vmx["ethernet0.addressType"] = "static"
            v.vmx["ethernet0.address"] = macaddr
        end

        node.vm.provision "install", type: "shell", inline: <<~SCRIPT
            export DEBIAN_FRONTEND=noninteractive
            apt-get install -y haproxy
        SCRIPT

        node.vm.provision "reload", after: "install", type: "shell", run: "never", inline: <<~SCRIPT
            cp /vagrant/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
            mkdir -p /etc/ssl/homenet/
            cat /vagrant/etc/kubernetes/pki/ingress.crt /vagrant/etc/kubernetes/pki/ingress.key /vagrant/etc/kubernetes/pki/ca.crt > \
                /etc/ssl/homenet/STAR_apps.homenet.pem
            systemctl reload haproxy
        SCRIPT
    end
end

