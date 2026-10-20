#!/bin/bash

source ../../misc.sh
source ./telemt.sh

load_settings

NAME="$1"

if [[ ! "$NAME" =~ ^[A-Za-z0-9_-]+$ ]]; then
    error "Использование: ./add_client.sh <имя> (латиница, цифры, _ и -)"
    exit 1
fi

if grep -q "^${NAME} " clients.txt 2>/dev/null; then
    error "Клиент ${NAME} уже есть"
    exit 1
fi

SECRET=$(openssl rand -hex 16)
echo "${NAME} ${SECRET}" >> clients.txt

# telemt сам перечитывает конфиг, перезапуск не нужен
generate_config "$(server_ip)"

log "Клиент ${NAME} добавлен. Ссылка:"
warn "$(client_link "$SECRET")"
