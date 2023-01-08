#!/bin/sh

mv /tmp/etc/dnsmasq.conf /etc/dnsmasq.conf
systemctl restart dnsmasq
