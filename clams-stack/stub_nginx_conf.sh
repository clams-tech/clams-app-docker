#!/bin/bash

set -ex
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

    ssl_certificate /certs/live/${CLAMS_FQDN}/fullchain.pem;
    ssl_certificate_key /certs/live/${CLAMS_FQDN}/privkey.pem;
    ssl_trusted_certificate /certs/live/${CLAMS_FQDN}/fullchain.pem;

    # http to https redirect.
    server {
        listen 80 default_server;
        server_name ${CLAMS_FQDN};
        return 301

        https://\$server_name\$request_uri;
    }


EOF

# else

#     cat >> "$NGINX_CONFIG_PATH" <<EOF
#     resolver 127.0.0.11;
# EOF

fi


SSL_TAG=""
SERVICE_INTERNAL_PORT=80
if [ "$ENABLE_TLS" = true ]; then
    SSL_TAG=" ssl"
    SERVICE_INTERNAL_PORT=443
fi

cat >> "$NGINX_CONFIG_PATH" <<EOF

    # server block for the clams browser-app; just a static website
    server {
        listen ${SERVICE_INTERNAL_PORT}${SSL_TAG};

        server_name ${CLAMS_FQDN};

        autoindex off;
        server_tokens off;
        
        gzip_static on;

        root /browser-app;
        index 200.html;
    }

EOF

# CLN listens on
STARTING_CLN_PORT=9736

# write out service for CLN; style is a docker stack deploy style,
# so we will use the replication feature
for (( CLN_ID=0; CLN_ID<$CLN_COUNT; CLN_ID++ )); do
    CLN_ALIAS="cln-${CLN_ID}"
    if [ "$ENABLE_TLS" = true ]; then
        cat >> "$NGINX_CONFIG_PATH" <<EOF
    map \$http_upgrade \$connection_upgrade {
        default upgrade;
        '' close;
    }

    # server block for the clightning websockets path;
    # this server block terminates TLS sessions and passes them to ws://.
    server {
        listen 9863${SSL_TAG};

        server_name ${CLAMS_FQDN};

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

    fi
done


# # Server block for ln-ws-proxy.
# if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
#     cat >> "$NGINX_CONFIG_PATH" <<EOF

#     server {
#         listen 443${SSL_TAG};

#         server_name ${LN_WS_PROXY_HOSTNAME};

#         location / {
#             # 127.0.0.1:3000 is the ln-ws-proxy service.
#             proxy_pass http://ln-ws-proxy:3000;
#             proxy_http_version 1.1;
#             proxy_set_header Upgrade \$http_upgrade;
#             proxy_set_header Connection 'upgrade';
#             proxy_set_header Host \$host;
#             proxy_cache_bypass \$http_upgrade;
#         }
#     }

# EOF
# fi


# close HTTP block
if [ "$OUTPUT_NGINX_FRAGMENTS" = true ]; then
    cat >> "$NGINX_CONFIG_PATH" <<EOF
}
EOF
fi
