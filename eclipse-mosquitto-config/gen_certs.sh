#!/bin/bash

mkdir -p certs

rm -f certs/*

cd certs

openssl genrsa -des3 -out rootCA.key 2048
openssl req -new -x509 -days 1826 -key rootCA.key -out rootCA.crt
openssl genrsa -out server.key 2048
openssl req -new -out server.csr -key server.key
openssl x509 -req -in server.csr -CA rootCA.crt -CAkey rootCA.key -CAcreateserial -out server.crt -days 360
