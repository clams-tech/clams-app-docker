#!/bin/bash

set -e
cd "$(dirname "$0")"

# close HTTP block
DOCKER_COMPOSE_YML_PATH="$(pwd)/docker-compose.yml"
touch "$DOCKER_COMPOSE_YML_PATH"

cat > "$DOCKER_COMPOSE_YML_PATH" <<EOF
version: "3.9"

services:
  reverse-proxy:
    image: nginx:latest
    restart: always
EOF


if { [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_BTC_BACKEND" = true ]; } || [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
    networks:
EOF


    if [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_BTC_BACKEND" = true ]; then
        cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
      - clightningnet
EOF
    fi

    if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
        cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
      - lnwsproxynet
EOF
    fi

fi

cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
    ports:
      - "${BIND_ADDR:-127.0.0.1}:80:80"
EOF

if [ "$ENABLE_TLS" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
      - "${BIND_ADDR:-127.0.0.1}:443:443"
EOF
fi

if [ "$DEPLOY_BTC_BACKEND" = true ] && [ "$ENABLE_TLS" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
      - "${BIND_ADDR}:${CLIGHTNING_WEBSOCKET_EXTERNAL_PORT:-7272}:9863"
EOF
fi

cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
    configs:
      - source: nginx-config
        target: /etc/nginx/nginx.conf
    volumes:
      - www-root:/browser-app
EOF

if [ "$ENABLE_TLS" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
      - certs:/certs
EOF
fi

if [ "$DEPLOY_LN_WS_PROXY" = true ]; then

    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
    
  ln-ws-proxy:
    container_name: ln-ws-proxy
    image: ${LN_WS_PROXY_IMAGE_NAME}
    restart: always
    networks:
      - lnwsproxynet
    expose:
      - '3000'
EOF

fi


if { [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_BTC_BACKEND" = true ]; } || [ "$DEPLOY_LN_WS_PROXY" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF

networks:
EOF


    if [ "$ENABLE_TLS" = true ] && [ "$DEPLOY_BTC_BACKEND" = true ]; then
        cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
  clightningnet:
    external: true
    name: backend_clightningnet
EOF
    fi

    if [ "$DEPLOY_LN_WS_PROXY" = true ]; then
        cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
  lnwsproxynet:
EOF
    fi

fi

    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF

volumes:
  www-root:
    external: true
    name: www-root
EOF


if [ "$ENABLE_TLS" = true ]; then
    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF
  certs:
    external: true
    name: clams-certs
EOF
fi



    cat >> "$DOCKER_COMPOSE_YML_PATH" <<EOF

configs:
  nginx-config:
    file: ${NGINX_CONFIG_PATH}

EOF
