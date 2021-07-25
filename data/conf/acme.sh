#!/bin/bash
export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DNS_SLOWRATE=2
acme.sh --issue -d DOMAIN --dns dns_aws --dnssleep 30

ROOTDIR="/root/ssl/conf"

mkdir $ROOTDIR/active

acme.sh --install-cert -d DOMAIN --key-file $ROOTDIR/privkey.pem --fullchain-file $ROOTDIR/fullchain.pem --reloadcmd "docker restart $(docker ps -a -q)"
