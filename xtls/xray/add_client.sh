#!/bin/bash

source ../../misc.sh
source ./xray.sh

NAME="$1"

if [[ -z "$NAME" ]]; then
    error "Использование: ./add_client.sh <имя>"
    exit 1
fi

if grep -q "^${NAME} " clients.txt 2>/dev/null; then
    error "Клиент ${NAME} уже есть"
    exit 1
fi

UUID=$(docker run --rm $IMAGE uuid)
echo "${NAME} ${UUID}" >> clients.txt

generate_config
restart_xray > /dev/null 2>&1 || { error "Не удалось перезапустить xray"; exit 1; }

log "Клиент ${NAME} добавлен. Ссылка:"
warn "$(client_link "$NAME" "$UUID")"
