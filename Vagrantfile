# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative "hosts.conf.rb"
require_relative "lib/node-dns.rb"
require_relative "lib/node-infra.rb"

Vagrant.configure("2") do |conf|
    dns(conf, name: "vh0-mac-vm-ub20-dns0", vmhost: "GPH00093m", macaddr: "00:0C:29:93:79:0E")
    infra(conf, name: "vh0-mac-vm-ub20-infra0", vmhost: "GPH00093m")
end
