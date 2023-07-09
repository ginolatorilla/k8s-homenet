# -*- mode: ruby -*-
# vi: set ft=ruby :

# Kubernetes for Home Network provisioner
# Inspired by by Artur Scheiner - artur.scheiner@gmail.com

BOX_IMAGE = "perk/ubuntu-2204-arm64"
CLUSTER_NAME = "k8s-homenet"
MASTER_COUNT = 1
WORKER_COUNT = 0
POD_CIDR = "172.18.0.0/16"
API_ADV_ADDRESS = "10.8.8.10"

Vagrant.configure("2") do |config|

  # Installing the necessary packages for this provisioner
  # References: https://computingforgeeks.com/install-kubernetes-cluster-ubuntu-jammy/
  config.vm.provision "shell" do |s|
      s.inline = <<-SCRIPT
        # Install Kubernetes
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get install -y apt-transport-https ca-certificates curl
        curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|  gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
        echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
        apt-get update
        apt-get install -y kubelet kubeadm kubectl
        apt-mark hold kubelet kubeadm kubectl

        # Disable swap
        swapoff -a
      SCRIPT
  end

  (0..MASTER_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-master-#{i}" do |subconfig|
      subconfig.vm.box = BOX_IMAGE
      subconfig.vm.hostname = "#{CLUSTER_NAME}-master-#{i}"
      subconfig.vm.network :private_network, ip: "10.8.8.#{i + 10}"
      subconfig.vm.provider :qemu do |qe, override|
        qe.smp = 2
        qe.memory = "1G"
        qe.ssh_port = "#{50022 + i}"
      end

      # This if is here just to remember me to create a multi-master cluster
      # the behavior and overal configuration is different and this will require a HAProxy installation
      if i == 0

        # subconfig.vm.provision "shell" do |s|
        #   s.inline = <<-SCRIPT
        #     mkdir -p /home/vagrant/.kv
        #     wget -q #{MASTER_SCRIPT_URL} -O /home/vagrant/.kv/master.sh
        #     chmod +x /home/vagrant/.kv/master.sh
        #     /home/vagrant/.kv/master.sh #{KVMSG} #{i} #{POD_CIDR} #{API_ADV_ADDRESS}
        #   SCRIPT
        # end

      end

    end
  end
  
  (0..WORKER_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-worker-#{i}" do |subconfig|
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
