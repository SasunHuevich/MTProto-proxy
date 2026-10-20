#!/bin/bash

source ../../misc.sh
source ./xray.sh

if [[ ! -f server.env ]]; then
    log "Генерирую ключи сервера..."
    init_server
fi

if [[ ! -s clients.txt ]]; then
    log "Создаю первого клиента..."
    echo "default $(docker run --rm $IMAGE uuid)" > clients.txt
fi

log "Создаю файл конфигурации..."
generate_config

log "Запускаю прокси..."
restart_xray || { error "Что-то пошло не так..."; error "Плак... Плак.."; exit 1; }

log "Успех! Ссылки для подключения:"
show_clients
