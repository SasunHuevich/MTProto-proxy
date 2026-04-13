#!/bin/bash

log() {
    GREEN='\033[0;32m'
    NC='\033[0m' # Сброс цвета (по умолчанию)

    echo -e "${GREEN}$1${NC}"
}

error() {
    RED='\033[0;31m'
    NC='\033[0m'  # Сброс цвета (по умолчанию)

    echo -e "${RED}$1${NC}" >&2
}

docker compose down

if [[ $? -eq 0 ]]; then
    log "Сервис остановлен!"
else
    error "Что-то пошло не так..."
    error "Плак... Плак.."
fi