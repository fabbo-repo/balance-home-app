#!/bin/bash

set -e

trap exit INT TERM

if [ -z "$DOMAIN" ]; then
  echo "DOMAIN environment variable is not set"
  exit 1;
fi

if [ -z "$EMAIL" ]; then
  echo "EMAIL environment variable is not set"
  exit 1;
fi

until nc -z nginx 80; do
  echo "Waiting for nginx to start..."
  sleep 5s & wait ${!}
done

mkdir -p "/var/www/certbot"

email_arg="--email $EMAIL"
echo "Obtaining the certificate for $DOMAIN with email $EMAIL"

certbot certonly \
    --webroot \
    -w "/var/www/certbot" \
    -d "$DOMAIN" -d "www.$DOMAIN" \
    $email_arg \
    --rsa-key-size "4096" \
    --agree-tos \
    --noninteractive \
    --verbose || true