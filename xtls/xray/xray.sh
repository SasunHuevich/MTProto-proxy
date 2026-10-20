#!/bin/bash

IMAGE="ghcr.io/xtls/xray-core:26.3.27"

# settings.env — домен для маскировки и порт (редактируется руками)
# server.env   — IP и ключи сервера (генерируются один раз)
# clients.txt — строки вида "имя uuid"

init_server() {
    local KEYS
    KEYS=$(docker run --rm $IMAGE x25519)

    cat > server.env << EOF2
IP=$(curl -s ifconfig.me)
PRIVATE_KEY=$(echo "$KEYS" | sed -n '1p' | awk -F': ' '{print $2}')
PUBLIC_KEY=$(echo "$KEYS" | sed -n '2p' | awk -F': ' '{print $2}')
SHORT_ID=$(openssl rand -hex 8)
XHTTP_PATH=/$(openssl rand -hex 6)
EOF2
}

generate_config() {
    source settings.env
    source server.env

    local CLIENTS=""
    local NAME UUID
    while read -r NAME UUID; do
        [[ -z "$NAME" ]] && continue
        CLIENTS+="${CLIENTS:+,}
          { \"id\": \"${UUID}\", \"email\": \"${NAME}\" }"
    done < clients.txt

    cat > config.json << EOF2
{
  "log": { "loglevel": "warning" },
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [${CLIENTS}
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "xhttp",
        "xhttpSettings": { "path": "${XHTTP_PATH}", "mode": "auto" },
        "security": "reality",
        "realitySettings": {
          "target": "${FAKE_DOMAIN}:443",
          "serverNames": ["${FAKE_DOMAIN}"],
          "privateKey": "${PRIVATE_KEY}",
          "shortIds": ["${SHORT_ID}"]
        }
      },
      "sniffing": { "enabled": true, "destOverride": ["http", "tls", "quic"] }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "tag": "direct" },
    { "protocol": "blackhole", "tag": "block" }
  ]
}
EOF2
}

client_link() {
    local NAME="$1"
    local UUID="$2"
    source settings.env
    source server.env

    echo "vless://${UUID}@${IP}:${PORT}?encryption=none&security=reality&sni=${FAKE_DOMAIN}&fp=chrome&pbk=${PUBLIC_KEY}&sid=${SHORT_ID}&type=xhttp&path=${XHTTP_PATH//\//%2F}&mode=auto#${NAME}"
}

show_clients() {
    local NAME UUID
    while read -r NAME UUID; do
        [[ -z "$NAME" ]] && continue
        log "${NAME}:"
        warn "$(client_link "$NAME" "$UUID")"
    done < clients.txt
}

restart_xray() {
    source settings.env
    PORT=$PORT docker compose up -d --force-recreate
}
