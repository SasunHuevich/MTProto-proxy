#!/bin/bash

source ../../misc.sh

FAKE_DOMAIN="ya.ru"
PORT="443"
IP=$(curl ifconfig.me)

log "Генерирую секрет..."

DOMAIN_HEX=$(echo -n "$FAKE_DOMAIN" | xxd -ps | tr -d '\n')
DOMAIN_LEN=${#DOMAIN_HEX}
RANDOM_HEX=$(openssl rand -hex 15 | cut -c1-$((30 - DOMAIN_LEN)))

SECRET="ee${DOMAIN_HEX}${RANDOM_HEX}"

log "Запускаю прокси..."

SECRET=$SECRET PORT=$PORT docker compose up -d --build

show_results "$IP" "$PORT" "$SECRET" "$FAKE_DOMAIN"