#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "If dnsmasq fails to start during installation, ignore it."
echo "We will have to stop systemd-resolved after (we can't stop if before"
echo "because we need to resolve Ubuntu servers)."
echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
apt-get update
apt-get install -y dnsmasq

systemctl disable systemd-resolved
systemctl stop systemd-resolved
systemctl enable dnsmasq
systemctl restart dnsmasq
