#!/bin/sh
mv /tmp/etc/haproxy.cfg /etc/haproxy/haproxy.cfg
systemctl reload haproxy
