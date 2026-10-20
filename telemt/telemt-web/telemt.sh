#!/bin/bash

# settings.env — домен (редактируется руками)
# clients.txt  — строки вида "имя секрет"

load_settings() {
    if [[ ! -f settings.env ]]; then
        error "Нет файла settings.env"
        exit 1
    fi

    source settings.env

    if [[ -z "$DOMAIN" || "$DOMAIN" == "web.example.com" ]]; then
        error "Впишите свой домен в settings.env"
        exit 1
    fi
}

generate_config() {
    local IP="$1"
    local NAME SECRET
    local USERS=""
    local PROFILES=""
    while read -r NAME SECRET; do
        [[ -z "$NAME" ]] && continue
        USERS+="\"${NAME}\" = \"${SECRET}\""$'\n'
        PROFILES+="
[[web.vhosts.profiles]]
user = \"${NAME}\"
secret_mode = \"dd\"
"
    done < clients.txt

    mkdir -p config
    cat > config/config.toml.tmp << EOF2
[general]
use_middle_proxy = true
log_level = "normal"

[general.modes]
classic = false
secure = true
tls = false

[general.links]
show = "*"

[server.api]
enabled = false

[[server.listeners]]
ip = "0.0.0.0"
port = 18080
transport = "web"
proxy_protocol = false
web_client_ip_source = "x_forwarded_for"
web_trusted_proxy_cidrs = ["172.30.77.10/32"]

[web]
enabled = true
carrier = "https"
carriers = ["websocket-lanes", "websocket", "https-lanes"]

[[web.vhosts]]
host = "${DOMAIN}"
public_addr = "${IP}:443"

[web.vhosts.decoy]
mode = "static_directory"
directory = "/srv/site"
index = "index.html"
${PROFILES}
[access.users]
${USERS}
EOF2
    mv config/config.toml.tmp config/config.toml
}

client_link() {
    local SECRET="$1"

    echo "tg://webproxy?server=${DOMAIN}&secret=dd${SECRET}"
}

show_clients() {
    local NAME SECRET
    while read -r NAME SECRET; do
        [[ -z "$NAME" ]] && continue
        log "${NAME}:"
        warn "$(client_link "$SECRET")"
    done < clients.txt
}

server_ip() {
    curl -s ifconfig.me
}
