# SSL-createCertReq.sh

``` 

#!/bin/sh

cat>/tmp/mkreq-$$.cf<<EOC
[ req ]
default_bits           = 1024
distinguished_name     = req_distinguished_name
prompt                 = no
x509_extensions        = rpext
keyUsage                = keyCertSign

[ req_distinguished_name ]
CN                      = $1
countryName            = NZ
localityName           = Auckland
organizationalUnitName = BeSTGRID
organizationName = Broadband enabled Science and Technology GRID

[rpext]
subjectKeyIdentifier=hash
authorityKeyIdentifier=keyid:always,issuer:always
extendedKeyUsage=serverAuth,clientAuth,emailProtection

EOC

if [ -d $1 ]; then
        echo "Certificate directory already exists!"
        if [ -e $1/$1.crt ]; then
                openssl x509 -in $1/$1.crt -noout -subject -issuer
        fi
        exit 1
else
        mkdir $1
fi

openssl req -config /tmp/mkreq-$$.cf -new -newkey rsa:1024 -sha1 -keyout $1/$1.key -nodes -out $1/$1.csr
rm -f /tmp/mkreq-$$.cf
echo "Successfully created certificate signing request"
openssl req -in $1/$1.csr -noout -text

```
