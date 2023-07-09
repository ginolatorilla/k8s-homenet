require 'socket'
require_relative 'node-base.rb'

def infra(config, vmhost:, name:)
    return if Socket.gethostname != vmhost

    base(config, vmhost)

    config.vm.define name do |node|
        node.vm.hostname = name

        node.vm.provider :vmware_desktop do |v|
            v.vmx["numvcpus"] = "1"
            v.vmx["memsize"] = "1024"
        end

        node.vm.provision "install", type: "shell", inline: <<-SCRIPT
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y avahi-daemon haproxy
        SCRIPT

        node.vm.provision "configure", type: "file", source: "./etc", destination: "/tmp/etc"

        node.vm.provision "reload", after: "configure", type: "shell", inline: <<-SCRIPT
            mv /tmp/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
            rm -rf /tmp/etc/
            systemctl reload haproxy
        SCRIPT
    end
end

