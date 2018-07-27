#!/bin/bash
workingPath="$PWD"
configurationPath="$PWD"/config

# rootCAName=root
rootCAName=root
serverName=server

passPhase=entonehd

rootCAConfig=root.csr.cnf
serverConfig=server.csr.cnf
v3File=v3.ext

isMakeCAAlso=1

if [ $isMakeCAAlso -eq 1 ]
then
    # generate Certification Authority's private key(.key)
    openssl genrsa -des3 -out $workingPath/${rootCAName}.key -passout pass:$passPhase 2048
    # generate Ceritfication Authority's certificate(.pem)
    openssl req -x509 -new -nodes -key $workingPath/${rootCAName}.key -sha256 -days 1024 -out $workingPath/${rootCAName}.pem -config $configurationPath/$rootCAConfig -passin pass:$passPhase
fi

# generate server certificate signing request(.csr) and server private key(.key)
sudo openssl req -new -sha256 -nodes -out $workingPath/${serverName}.csr -newkey rsa:2048 -keyout $workingPath/${serverName}.key -config $configurationPath/$serverConfig
# generate server certificate(.crt)
sudo openssl x509 -req -in $workingPath/${serverName}.csr -CA $workingPath/${rootCAName}.pem -CAkey $workingPath/${rootCAName}.key -CAcreateserial -out $workingPath/${serverName}.crt -days 500 -sha256 -extfile $configurationPath/$v3File -passin pass:$passPhase

#######################################################################################
# checking
openssl x509 -text -in $workingPath/${serverName}.crt -noout

#######################################################################################
# comment for config file

# C=Country Name
# ST=State or Province Name
# L=Local Name (city)
# O=Organization Name
# OU=Orgnaination Unit
# CN=Common Name (e.g. server FQDN or YOUR name)
