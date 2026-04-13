#!/bin/bash

FAKE_DOMAIN="ya.ru"
PORT="443"
IP=$(curl ifconfig.me)

log() {
    GREEN='\033[0;32m'
    NC='\033[0m' # Сброс цвета (по умолчанию)

    echo -e "${GREEN}$1${NC}"
}

warn() {
    YELLOW='\033[0;33m'
    NC='\033[0m'  # Сброс цвета (по умолчанию)
    
    echo -e "${YELLOW}$1${NC}" >&2
}

error() {
    RED='\033[0;31m'
    NC='\033[0m'  # Сброс цвета (по умолчанию)

    echo -e "${RED}$1${NC}" >&2
}

log "Генерирую секрет..."


DOMAIN_HEX=$(echo -n "$FAKE_DOMAIN" | xxd -ps | tr -d '\n')
DOMAIN_LEN=${#DOMAIN_HEX}
RANDOM_HEX=$(openssl rand -hex 15 | cut -c1-$((30 - DOMAIN_LEN)))

SECRET="ee${DOMAIN_HEX}${RANDOM_HEX}"

log "Запускаю прокси..."

SECRET=$SECRET PORT=$PORT docker compose up -d --build

if [[ $? -eq 0 ]]; then
    log "Успех!"
    log "Параметры прокси:"
    log "IP: $IP"
    log "PORT: $PORT"
    log "SECRET: $SECRET"

    log "Сcылка для подключения:"
    warn "tg://proxy?server=${IP}&port=${PORT}&secret=${SECRET}"

    cat > proxy_config.txt << EOF
SERVER=${IP}
PORT=${PORT}
SECRET=${SECRET}
DOMAIN=${FAKE_DOMAIN}
LINK=tg://proxy?server=${IP}&port=${PORT}&secret=${SECRET}
EOF

else
    error "Что-то пошло не так..."
    error "Плак... Плак.."
fi