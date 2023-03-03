#!/bin/bash

set -e
cd "$(dirname "$0")"

# run the build script.
./build.sh

. ./.env

# stub out the nginx config
NGINX_CONFIG_PATH=./nginx.conf
cat > "$NGINX_CONFIG_PATH" <<EOF

events {
    worker_connections 1024;
}

http {

    server {
        listen ${LN_WS_PROXY_EXTERNAL_PORT};

        server_name ${LN_WS_PROXY_DOMAIN_NAME};

        location / {
            # 127.0.0.1:3000 is the ln-ws-proxy service.
            proxy_pass http://ln-ws-proxy:3000;
            proxy_http_version 1.1;
            proxy_set_header Upgrade \$http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host \$host;
            proxy_cache_bypass \$http_upgrade;
        }
    }
}

EOF

docker compose up -d

echo "The ln-ws-proxy service is available at http://${LN_WS_PROXY_BIND_ADDR}:${LN_WS_PROXY_EXTERNAL_PORT}"