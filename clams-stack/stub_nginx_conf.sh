#!/bin/bash

set -e
cd "$(dirname "$0")"

cat > "$NGINX_CONFIG_PATH" <<EOF
events {
    worker_connections 1024;
}

http {
    include mime.types;
    sendfile on;

EOF

if [ "$ENABLE_TLS" = true ]; then

    cat >> "$NGINX_CONFIG_PATH" <<EOF
    # global TLS settings
    ssl_prefer_server_ciphers on;
    ssl_protocols TLSv1.3;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    add_header Strict-Transport-Security "max-age=63072000" always;
    ssl_stapling on;
    ssl_stapling_verify on;

    ssl_certificate /certs/live/${DOMAIN_NAME}/fullchain.pem;
    ssl_certificate_key /certs/live/${DOMAIN_NAME}/privkey.pem;
    ssl_trusted_certificate /certs/live/${DOMAIN_NAME}/fullchain.pem;

    # http to https redirect.
    server {
        listen 80 default_server;
        server_name ${DOMAIN_NAME};
        return 301

        https://\$server_name\$request_uri;
    }


EOF

# else

    cat >> "$NGINX_CONFIG_PATH" <<EOF
    resolver 127.0.0.11;
EOF

fi


SSL_TAG=""
SERVICE_INTERNAL_PORT=80
if [ "$ENABLE_TLS" = true ]; then
    SSL_TAG=" ssl"
    SERVICE_INTERNAL_PORT=443
fi

if [ "$DEPLOY_PRISM_BROWSER_APP" = true ]; then
    cat >> "$NGINX_CONFIG_PATH" <<EOF

    # https server block for the prism app
    server {
        listen ${SERVICE_INTERNAL_PORT}${SSL_TAG};

        server_name ${DOMAIN_NAME};

        location / {
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host \$http_host;
            proxy_cache_bypass \$http_upgrade;

            proxy_read_timeout     60;
            proxy_connect_timeout  60;
            proxy_redirect         off;

            proxy_pass http://prism-browser-app:5173;
        }
    }
EOF

    if [ "$DEPLOY_CLAMS_BROWSER_APP" = true ]; then
        cat >> "$NGINX_CONFIG_PATH" <<EOF

        location /clams/ {
            autoindex off;
            server_tokens off;
            gzip_static on;
            root /browser-app;
            index 200.html;
        }
    }

EOF
    fi
fi

STARTING_WEBSOCKET_PORT=9736

# write out service for CLN; style is a docker stack deploy style,
# so we will use the replication feature
for (( CLN_ID=0; CLN_ID<$CLN_COUNT; CLN_ID++ )); do
    CLN_ALIAS="cln-${CLN_ID}"
    CLN_WEBSOCKET_PORT=$(( $STARTING_WEBSOCKET_PORT+$CLN_ID ))
    cat >> "$NGINX_CONFIG_PATH" <<EOF
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        '' close;
    }

    # server block for the clightning websockets path;
    # this server block terminates TLS sessions and passes them to ws://.
    server {
        listen ${CLN_WEBSOCKET_PORT}${SSL_TAG};

        server_name ${DOMAIN_NAME};

        location / {
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Proxy "";
            proxy_set_header Host \$http_host;
            proxy_set_header X-Real-IP \$remote_addr;
            proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto \$scheme;

            proxy_pass http://${CLN_ALIAS}:9736;
        }
    }

EOF


if [ "$DEPLOY_CLAMS_BROWSER_APP" = true ]; then
    cat >> "$NGINX_CONFIG_PATH" <<EOF

    # server block for the clams browser-app; just a static website
    server {
        listen ${SERVICE_INTERNAL_PORT}${SSL_TAG};

        server_name ${CLN_FQDN};

        autoindex off;
        server_tokens off;
        
        gzip_static on;

        root /browser-app;
        index 200.html;
    }

EOF
fi

done

    cat >> "$NGINX_CONFIG_PATH" <<EOF
}
EOF