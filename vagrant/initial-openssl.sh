#!/bin/bash

## Provision the Root Certificate Authority for use with OpenSSL

## This file gets executed the first time you do a `vagrant up`, if you want it to
## run again you'll need run `vagrant provision`

CERTIFICATE_PASSWORD=vagrant

########################################################################################################################
## Initial provisioning of root CA directory structure
########################################################################################################################

export SAN="DNS:vagrant.up,DNS:*.vagrant.up"

if [ ! -d "/root/ca" ]
then
    mkdir /root/ca
    cd /root/ca
    mkdir certs crl newcerts private
    chmod 700 private
    touch index.txt
    echo 1000 > serial

    cp /vagrant/vagrant/files/ssl/openssl.cnf /root/ca
fi

########################################################################################################################
## Root Certificate
########################################################################################################################

# Generate the Root CA keys. The password is $CERTIFICATE_PASSWORD
if [ ! -f "/root/ca/private/ca.key.pem" ]
then
    cd /root/ca
    openssl genrsa -aes256 -passout pass:$CERTIFICATE_PASSWORD -out private/ca.key.pem 4096
    chmod 400 private/ca.key.pem
fi

# Create the root certificate
if [ ! -f "/root/ca/certs/ca.cert.pem" ]
then
    cd /root/ca
    openssl req -config openssl.cnf \
          -key private/ca.key.pem \
          -passin pass:$CERTIFICATE_PASSWORD \
          -new -x509 -days 7300 -sha256 -extensions v3_ca \
          -subj '/CN=Akeeba Ltd Vagrant Box Root CA/O=Akeeba Ltd./OU=Production Department/C=CY/ST=Nicosia/L=Egkomi' \
          -out certs/ca.cert.pem
    chmod 444 certs/ca.cert.pem
fi

########################################################################################################################
## Intermediate pair
########################################################################################################################

if [ ! -d "/root/ca/intermediate" ]
then
    # Create the folder structure for the intermediate pair
    mkdir /root/ca/intermediate
    cd /root/ca/intermediate
    mkdir certs crl csr newcerts private
    chmod 700 private
    touch index.txt
    echo 1000 > serial
    echo 1000 > /root/ca/intermediate/crlnumber

    cp  /vagrant/vagrant/files/ssl/intermediate-openssl.cnf /root/ca/intermediate/openssl.cnf
fi

# Create the intermediate key
if [ ! -f "/root/ca/intermediate/private/intermediate.key.pem" ]
then
    cd /root/ca
    openssl genrsa -aes256 \
          -passout pass:$CERTIFICATE_PASSWORD \
          -out intermediate/private/intermediate.key.pem 4096
    chmod 400 intermediate/private/intermediate.key.pem
fi


# Create the intermediate certificate
if [ ! -f "/root/ca/intermediate/certs/intermediate.cert.pem" ]
then
    cd /root/ca
    # -- CSR
    openssl req -config intermediate/openssl.cnf -new -sha256 \
          -key intermediate/private/intermediate.key.pem \
          -passin pass:$CERTIFICATE_PASSWORD \
          -subj '/CN=Akeeba Ltd Vagrant Box Intermediate CA/O=Akeeba Ltd./OU=Production Department/C=CY/ST=Nicosia/L=Egkomi' \
          -out intermediate/csr/intermediate.csr.pem
    # -- Sign the key
    openssl ca -config openssl.cnf -extensions v3_intermediate_ca -batch \
          -passin pass:$CERTIFICATE_PASSWORD \
          -days 3650 -notext -md sha256 \
          -in intermediate/csr/intermediate.csr.pem \
          -out intermediate/certs/intermediate.cert.pem
    chmod 444 intermediate/certs/intermediate.cert.pem

    # Create the certificate chain file
    cat intermediate/certs/intermediate.cert.pem \
          certs/ca.cert.pem > intermediate/certs/ca-chain.cert.pem
    chmod 444 intermediate/certs/ca-chain.cert.pem
fi

########################################################################################################################
## Create and publish the Certificate Revocation List
########################################################################################################################
# The CRL has a maximum age of 30 days. As a result we need to regenerate it frequently. The best way is to add this to
# the provisioning scripts since we tend to run them every month or so, when new PHP versions are released.
cd /root/ca
openssl ca -config intermediate/openssl.cnf \
      -passin pass:$CERTIFICATE_PASSWORD \
      -gencrl -out intermediate/crl/intermediate.crl.pem
cp /root/ca/intermediate/crl/intermediate.crl.pem /var/www/intermediate.crl.pem
chmod 0644 /var/www/intermediate.crl.pem

########################################################################################################################
## Done!
########################################################################################################################
exit 0