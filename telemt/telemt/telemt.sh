#!/bin/bash

# settings.env — домен и порт (редактируется руками)
# clients.txt  — строки вида "имя секрет"

load_settings() {
    if [[ ! -f settings.env ]]; then
        error "Нет файла settings.env"
        exit 1
    fi

    source settings.env

    if [[ -z "$DOMAIN" || "$DOMAIN" == "proxy.example.com" ]]; then
        error "Впишите свой домен в settings.env"
        exit 1
    fi
}

generate_config() {
    local NAME SECRET
    local USERS=""
    while read -r NAME SECRET; do
        [[ -z "$NAME" ]] && continue
        USERS+="\"${NAME}\" = \"${SECRET}\""$'\n'
    done < clients.txt

    mkdir -p config
    cat > config/config.toml.tmp << EOF2
[general]
use_middle_proxy = true
log_level = "normal"

[general.modes]
classic = false
secure = false
tls = true

[general.links]
show = "*"
public_host = "${DOMAIN}"
public_port = ${PORT}

[server]
port = 443

[server.api]
enabled = false

[[server.listeners]]
ip = "0.0.0.0"

[censorship]
tls_domain = "${DOMAIN}"
mask = true
mask_host = "caddy"
mask_port = 8443
tls_emulation = true
tls_front_dir = "tlsfront"

[access.users]
${USERS}
EOF2
    mv config/config.toml.tmp config/config.toml
}

client_link() {
    local SECRET="$1"
    local DOMAIN_HEX
    DOMAIN_HEX=$(printf '%s' "$DOMAIN" | od -An -tx1 | tr -d ' \n')

    echo "tg://proxy?server=${DOMAIN}&port=${PORT}&secret=ee${SECRET}${DOMAIN_HEX}"
}

show_clients() {
    local NAME SECRET
    while read -r NAME SECRET; do
        [[ -z "$NAME" ]] && continue
        log "${NAME}:"
        warn "$(client_link "$SECRET")"
    done < clients.txt
}
