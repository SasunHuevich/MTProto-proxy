#!/bin/bash

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

show_results() {
    local IP="$1"
    local PORT="$2"
    local SECRET="$3"
    local FAKE_DOMAIN="$4"

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
}

docker_down() {
    docker compose down

    if [[ $? -eq 0 ]]; then
        log "Сервис остановлен!"
    else
        error "Что-то пошло не так..."
        error "Плак... Плак.."
    fi
}