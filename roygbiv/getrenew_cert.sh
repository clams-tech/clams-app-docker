#!/bin/bash

set -e
cd "$(dirname "$0")"

# let's do a refresh of the certificates. Let's Encrypt will not run if it's not time.
CERTBOT_IMAGE_NAME="certbot/certbot:latest"
docker pull "$CERTBOT_IMAGE_NAME"

OTHER_HOSTNAMES=""
if [ "$DEPLOY_CLAMS_BROWSER_APP" = true ]; then
    OTHER_HOSTNAMES="-d $CLAMS_FQDN"
fi

GET_CERT_STRING="docker run -it --rm --name certbot -p 80:80 -p 443:443 -v roygbiv-certs:/etc/letsencrypt ${CERTBOT_IMAGE_NAME} certonly -v --noninteractive --agree-tos --key-type ecdsa --standalone --expand -d ${DOMAIN_NAME} ${OTHER_HOSTNAMES} --email info@${DOMAIN_NAME}"

# execute the certbot command
eval "$GET_CERT_STRING"
