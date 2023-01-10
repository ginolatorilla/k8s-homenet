#!/bin/sh
# This is meant to be called by the virtual machines, and always called first.
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y avahi-daemon
swapoff -a
sed 's|/swap|#/swap|g' -i /etc/fstab