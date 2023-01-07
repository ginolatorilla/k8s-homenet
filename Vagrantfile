# -*- mode: ruby -*-
# vi: set ft=ruby :

# Kubernetes for Home Network provisioner
# Inspired by by Artur Scheiner - artur.scheiner@gmail.com

BOX_IMAGE = "perk/ubuntu-2204-arm64"
CLUSTER_NAME = "k8s-homenet"
MASTER_COUNT = 1
WORKER_COUNT = 0
INFRA_COUNT = 1
POD_CIDR = "172.18.0.0/16"
API_ADV_ADDRESS = "10.8.8.10"

Vagrant.configure("2") do |config|

  (0..MASTER_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-master-#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = "#{CLUSTER_NAME}-master-#{i}"
      node.vm.provider :qemu do |qe, override|
        qe.smp = 2
        qe.memory = "2G"
        qe.ssh_port = "#{50022 + i}"
      end

      node.vm.provision "shell", path: "./install-master.sh", args: [CLUSTER_NAME, POD_CIDR]
    end
  end
  
  (0..INFRA_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-infra-#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "#{CLUSTER_NAME}-worker-#{i}"
      subconfig.vm.network :private_network, ip: "10.8.8.#{i + 20}"
      subconfig.vm.provider :qemu do |qe, override|
        qe.smp = 2
        qe.memory = "1G"
        qe.ssh_port = "#{60022 + i}"
      end

      # subconfig.vm.provision "shell" do |s|
      #   s.inline = <<-SCRIPT
      #     mkdir -p /home/vagrant/.kv
      #     wget -q #{WORKER_SCRIPT_URL} -O /home/vagrant/.kv/worker.sh
      #     chmod +x /home/vagrant/.kv/worker.sh
      #     /home/vagrant/.kv/worker.sh #{KVMSG} #{i} #{POD_CIDR} #{API_ADV_ADDRESS}
      #   SCRIPT
      # end

    end
  end
end
