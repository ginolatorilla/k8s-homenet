#!/bin/sh
pushd "$( dirname "${BASH_SOURCE[0]}" )"/..

openssl genrsa -out etc/kubernetes/pki/ingress.key 4096
openssl req -new -key etc/kubernetes/pki/ingress.key -config scripts/openssl-ingress-csr.cnf -out etc/kubernetes/pki/ingress.csr

openssl x509 -req -sha256 -days 3650 -in etc/kubernetes/pki/ingress.csr \
    -extfile scripts/openssl-ingress-cert.cnf -out etc/kubernetes/pki/ingress.crt \
    -CAcreateserial -CA etc/kubernetes/pki/ca.crt -CAkey etc/kubernetes/pki/ca.key

popd