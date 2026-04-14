#!/bin/bash

source ../../misc.sh

FAKE_DOMAIN="update.microsoft.com"
PORT="443"
IP=$(curl -s ifconfig.me)

log "Создаю файл конфигурации..."
SECRET=$(docker run --rm nineseconds/mtg:2 generate-secret --hex $FAKE_DOMAIN)

cat > config.toml << EOF
secret = "${SECRET}"
bind-to = "0.0.0.0:443"
EOF

log "Запускаю прокси..."

PORT=$PORT docker compose up -d --build

show_results "$IP" "$PORT" "$SECRET" "$FAKE_DOMAIN"