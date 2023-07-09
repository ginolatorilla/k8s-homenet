#!/bin/sh
pushd "$( dirname "${BASH_SOURCE[0]}" )"/..

rm -rf etc/kubernetes/pki
mkdir -p etc/kubernetes/pki/etcd

openssl req -x509 -sha256 -days 3650 -nodes -newkey rsa:4096 -config scripts/openssl.cnf -batch -set_serial 0 \
    -extensions v3_ca -keyout etc/kubernetes/pki/ca.key -out etc/kubernetes/pki/ca.crt -verbose
cp etc/kubernetes/pki/ca.key etc/kubernetes/pki/front-proxy-ca.key
cp etc/kubernetes/pki/ca.crt etc/kubernetes/pki/front-proxy-ca.crt
cp etc/kubernetes/pki/ca.key etc/kubernetes/pki/etcd/ca.key
cp etc/kubernetes/pki/ca.crt etc/kubernetes/pki/etcd/ca.crt

popd