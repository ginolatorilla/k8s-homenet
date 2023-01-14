#!/bin/sh
infra0_ip="$(avahi-resolve-host-name -4 vh0-mac-vm-ub20-infra0.local | awk '{print $2}')"
# We want to default to localhost because dnsmasq will fail if it uses its default config
# due to the systemd-resolved service not running to provide /etc/resolv.conf
sed "s/{infra0_ip}/${infra0_ip:-127.0.0.1}/g" /etc/dnsmasq.conf.template > /etc/dnsmasq.conf
systemctl restart dnsmasq