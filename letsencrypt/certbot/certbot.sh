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

email_arg="-m $EMAIL"
echo "Obtaining the certificate for $DOMAIN with email $EMAIL"

certbot certonly \
    --webroot \
    --preferred-challenges=http \
    -w "/var/www/certbot" \
    -d "$DOMAIN" -d "www.$DOMAIN" \
    $email_arg \
    --rsa-key-size "4096" \
    --no-eff-email \
    --agree-tos \
    -n || true
