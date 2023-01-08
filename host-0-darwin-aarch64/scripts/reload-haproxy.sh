#!/bin/sh
mv /tmp/etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg
systemctl reload haproxy
