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

openssl genrsa -out etc/kubernetes/pki/ingress.key 4096
openssl req -new -key etc/kubernetes/pki/ingress.key -config scripts/openssl-ingress-csr.cnf -out etc/kubernetes/pki/ingress.csr

openssl x509 -req -sha256 -days 3650 -in etc/kubernetes/pki/ingress.csr \
    -extfile scripts/openssl-ingress-cert.cnf -out etc/kubernetes/pki/ingress.crt \
    -CAcreateserial -CA etc/kubernetes/pki/ca.crt -CAkey etc/kubernetes/pki/ca.key

popd