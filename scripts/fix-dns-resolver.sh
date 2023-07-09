#!/bin/sh
dns0_ip="$(avahi-resolve-host-name -4 vh0-mac-vm-ub20-dns0.local | awk '{print $2}')"
sed "s/{dns0_ip}/${dns0_ip}/g" /vagrant/etc/systemd/resolved.conf.template > /etc/systemd/resolved.conf
systemctl restart systemd-resolved
