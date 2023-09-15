#!/bin/bash
# generate certificate request for UoA server
# arguments: $1 - server hostname

INSTITUTION="Name of your Institution"
EMAIL="gridadmin@your.site.domain"
HOSTNAME=$1

openssl req -new  -newkey rsa:2048  -nodes -keyout hostkey.pem -out ${HOSTNAME}_request.pem -keyout ${HOSTNAME}_key.pem  \
    -subj "/C=NZ/O=BeSTGRID/OU=${INSTITUTION}/CN=${HOSTNAME}/emailAddress=${EMAIL}"


