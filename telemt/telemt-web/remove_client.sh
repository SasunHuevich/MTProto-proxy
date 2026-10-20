#!/bin/bash

source ../../misc.sh
source ./telemt.sh

load_settings

NAME="$1"

if ! grep -q "^${NAME} " clients.txt 2>/dev/null; then
    error "Клиент ${NAME} не найден"
    exit 1
fi

grep -v "^${NAME} " clients.txt > clients.tmp && mv clients.tmp clients.txt

generate_config "$(server_ip)"

log "Клиент ${NAME} удалён"
