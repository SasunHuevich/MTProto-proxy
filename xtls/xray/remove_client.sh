#!/bin/bash

source ../../misc.sh
source ./xray.sh

NAME="$1"

if ! grep -q "^${NAME} " clients.txt 2>/dev/null; then
    error "Клиент ${NAME} не найден"
    exit 1
fi

grep -v "^${NAME} " clients.txt > clients.tmp && mv clients.tmp clients.txt

generate_config
restart_xray > /dev/null 2>&1 || { error "Не удалось перезапустить xray"; exit 1; }

log "Клиент ${NAME} удалён"
