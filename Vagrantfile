# -*- mode: ruby -*-
# vi: set ft=ruby :

# Kubernetes for Home Network provisioner
# Inspired by by Artur Scheiner - artur.scheiner@gmail.com

BOX_IMAGE = "starboard/ubuntu-arm64-20.04.5"
BOX_VERSION = "20221120.20.40.0"
CLUSTER_NAME = "k8s-homenet"
MASTER_COUNT = 1
WORKER_COUNT = 0
INFRA_COUNT = 0
POD_CIDR = "172.18.0.0/16"
API_ADV_ADDRESS = "10.8.8.10"

Vagrant.configure("2") do |config|

  (0..MASTER_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-master-#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.box_version = BOX_VERSION
      node.vm.hostname = "#{CLUSTER_NAME}-master-#{i}"
      node.vm.provider "vmware_desktop" do |v, override|
        v.ssh_info_public = true
        v.gui = true
        v.linked_clone = false
        v.vmx["numvcpus"] = "2"
        v.vmx["memsize"] = "2048"
        v.vmx["ethernet0.virtualdev"] = "vmxnet3"
      end
      node.vm.provision "shell", path: "./install-master.sh", args: [CLUSTER_NAME, POD_CIDR]
    end
  end
  
  (0..INFRA_COUNT-1).each do |i|
    config.vm.define "#{CLUSTER_NAME}-infra-#{i}" do |node|
      node.vm.box = BOX_IMAGE
      node.vm.hostname = "#{CLUSTER_NAME}-infra-#{i}"
      node.vm.provider :qemu do |qe, override|
        qe.smp = 2
        qe.memory = "1G"
        qe.ssh_port = "#{60022 + i}"  
        qe.extra_netdev_args = "id=privnet,net=192.168.76.0/24,dhcpstart=192.168.76.#{9 + i}"
      end

      node.vm.provision "shell", path: "./install-infra.sh"
    end
  end
end
