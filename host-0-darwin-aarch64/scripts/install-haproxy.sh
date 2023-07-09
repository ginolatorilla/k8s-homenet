#!/bin/sh
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y haproxy
systemctl enable haproxy
