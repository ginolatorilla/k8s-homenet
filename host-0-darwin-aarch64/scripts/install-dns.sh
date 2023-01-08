#!/bin/sh
systemctl disable systemd-resolved.service 
systemctl stop systemd-resolved.service

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y dnsmasq
