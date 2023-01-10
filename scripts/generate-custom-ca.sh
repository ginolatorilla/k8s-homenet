#!/bin/sh
pushd "$( dirname "${BASH_SOURCE[0]}" )"/..

rm -rf etc/kubernetes/pki
mkdir -p etc/kubernetes/pki/etcd

SUBJECT="/CN=Personal Authority of Gino Latorilla and Rowejoi Romulo/C=PH/O=Gino Latorilla's Home Network"
openssl req -x509 -sha256 -days 356 -nodes -newkey rsa:2048 -subj "$SUBJECT" -keyout etc/kubernetes/pki/ca.key -out etc/kubernetes/pki/ca.crt
cp etc/kubernetes/pki/ca.key etc/kubernetes/pki/front-proxy-ca.key
cp etc/kubernetes/pki/ca.crt etc/kubernetes/pki/front-proxy-ca.crt
cp etc/kubernetes/pki/ca.key etc/kubernetes/pki/etcd/ca.key
cp etc/kubernetes/pki/ca.crt etc/kubernetes/pki/etcd/ca.crt
popd