#!/bin/bash

source ../../misc.sh
source ./telemt.sh

load_settings

IP=$(curl -s ifconfig.me)
DOMAIN_IP=$(getent hosts "$DOMAIN" 2>/dev/null | awk '{print $1}' | head -1)
if [[ "$DOMAIN_IP" != "$IP" ]]; then
    warn "Внимание: ${DOMAIN} указывает на '${DOMAIN_IP}', а IP сервера ${IP}"
    warn "Без правильной A-записи не выпустится сертификат и не будут работать ссылки"
fi

if [[ ! -s clients.txt ]]; then
    log "Создаю первого клиента..."
    echo "default $(openssl rand -hex 16)" > clients.txt
fi

log "Создаю файл конфигурации..."
generate_config

log "Запускаю прокси..."
DOMAIN=$DOMAIN PORT=$PORT docker compose up -d || { error "Что-то пошло не так..."; error "Плак... Плак.."; exit 1; }

log "Успех! Ссылки для подключения:"
show_clients
