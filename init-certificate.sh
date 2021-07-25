#!/bin/bash

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
export AWS_DNS_SLOWRATE=2

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

data_path="/root/ssl"

mkdir -p "$data_path"

read -p "Enter domain name (eg. www.example.com): " domains

if [ -d "$data_path" ]; then
  read -p "Existing data found. Continue and replace existing certificate? (y/N) " decision
  if [ "$decision" != "Y" ] && [ "$decision" != "y" ]; then
    exit
  fi
fi


if [ ! -e "$data_path/conf/options-ssl-nginx.conf" ] || [ ! -e "$data_path/conf/ssl-dhparams.pem" ]; then
  echo "### Downloading recommended TLS parameters ..."
  mkdir -p "$data_path/conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot-nginx/certbot_nginx/_internal/tls_configs/options-ssl-nginx.conf > "$data_path/conf/options-ssl-nginx.conf"
  curl -s https://raw.githubusercontent.com/certbot/certbot/master/certbot/certbot/ssl-dhparams.pem > "$data_path/conf/ssl-dhparams.pem"
  echo
fi

echo "### Requesting Let's Encrypt certificate for $domains ..."
#Join $domains to -d args
domain_args=""
for domain in "${domains[@]}"; do
  domain_args="$domain_args -d $domain"
done

acme.sh --issue -d $domain_args --dns dns_aws --dnssleep 30

acme.sh --install-cert -d $domain_args \
  --key-file $data_path/conf/live/$domain/privkey.pem \
  --fullchain-file $data_path/conf/live/$domain/fullchain.pem \
  --reloadcmd "docker restart $(docker ps -a -q)" && \
    ln -fs $data_path/conf/live/$domains/ $data_path/conf/active
echo
echo "After running 'docker-compose up --detach' you can share your proxy as: https://signal.tube/#$domains"
