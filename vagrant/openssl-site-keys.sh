#!/bin/bash

# Check the number arguments
if [ "$#" -ne 1 ]
then
	echo "Invalid number of parameters. Usage:"
	echo "  openssl-site-keys.sh hostname"
	echo "Where:"
	echo "  hostname  Base hostname for the certificate, e.g. example.com"
	echo ""
	echo "The generated files are saved in the directory /root/ca/intermediate/certs and copied to"
	echo "/etc/apache2/ssl"
	exit 255
fi

CERTIFICATE_PASSWORD=vagrant
CERTHOSTNAME=$1

cd /root/ca

# Make a key file if one doesn't already exist
if [[ ! -f "intermediate/private/$CERTHOSTNAME.key.pem" ]]
then
    openssl genrsa -aes256 \
          -passout pass:$CERTIFICATE_PASSWORD \
          -out intermediate/private/$CERTHOSTNAME.key.pem 2048
    chmod 400 intermediate/private/$CERTHOSTNAME.key.pem
fi


# Make a CSR if one doesn't already exist
if [[ ! -f "intermediate/private/$CERTHOSTNAME.csr.pem" ]]
then
    export SAN="DNS:$CERTHOSTNAME,DNS:*.$CERTHOSTNAME"

    openssl req -config intermediate/openssl.cnf \
          -key intermediate/private/$CERTHOSTNAME.key.pem \
          -extensions san_env \
          -passin pass:$CERTIFICATE_PASSWORD \
          -subj "/CN=*.$CERTHOSTNAME/O=Akeeba Ltd./OU=Production Department/C=CY/ST=Nicosia/L=Egkomi" \
          -new -sha256 -out intermediate/csr/$CERTHOSTNAME.csr.pem

fi

# Sign a certificate if one doesn't already exist
if [[ ! -f "intermediate/certs/$CERTHOSTNAME.cert.pem" ]]
then
    export SAN="DNS:$CERTHOSTNAME,DNS:*.$CERTHOSTNAME"

    openssl ca -config intermediate/openssl.cnf -batch \
          -extensions server_cert -extensions san_env \
          -days 1835 -notext -md sha256 \
          -in intermediate/csr/$CERTHOSTNAME.csr.pem \
          -passin pass:$CERTIFICATE_PASSWORD \
          -out intermediate/certs/$CERTHOSTNAME.cert.pem
    chmod 444 intermediate/certs/$CERTHOSTNAME.cert.pem
fi

if [[ ! -d /etc/apache2/ssl ]]
then
    mkdir /etc/apache2/ssl
    chmod 0755 /etc/apache2/ssl
fi

# Copy the certificate files
cp /root/ca/intermediate/certs/ca-chain.cert.pem /etc/apache2/ssl/ca-chain.crt
openssl rsa -in /root/ca/intermediate/private/$CERTHOSTNAME.key.pem \
    -out /etc/apache2/ssl/$CERTHOSTNAME.key \
    -passin pass:$CERTIFICATE_PASSWORD
cp /root/ca/intermediate/certs/$CERTHOSTNAME.cert.pem /etc/apache2/ssl/$CERTHOSTNAME.crt
chmod 0644 /etc/apache2/ssl/*
