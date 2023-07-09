# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative "config.rb"
require_relative "lib/node-dns.rb"
require_relative "lib/node-infra.rb"
require_relative "lib/node-k8s.rb"

Vagrant.configure("2") do |conf|
    dns(conf, name: "vh0-mac-vm-ub20-dns0", vmhost: "GPH00093m", macaddr: "00:0C:29:93:79:0E")
    infra(conf, name: "vh0-mac-vm-ub20-infra0", vmhost: "GPH00093m", macaddr: "00:0C:29:69:2A:FB")
    k8s_node(conf, name: "vh0-mac-vm-ub20-master0", vmhost: "GPH00093m", type: "control-leader")
    k8s_node(conf, name: "vh0-mac-vm-ub20-worker0", vmhost: "GPH00093m", type: "worker", size: :large)
    k8s_node(conf, name: "vh0-mac-vm-ub20-worker1", vmhost: "GPH00093m", type: "worker", size: :large)
end
