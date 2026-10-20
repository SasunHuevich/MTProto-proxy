### Небходимые утитлиты
- curl
- openssl
- docker
- docker compose

### Что это
VLESS + XHTTP + Reality (Xray). Трафик выглядит как HTTPS к `FAKE_DOMAIN`, ключи и отпечаток — как у настоящего Chrome.

### Использование
- `./start_proxy.sh` — первый запуск генерирует ключи (`server.env`) и клиента `default`
- `./add_client.sh <имя>` — новый клиент, выдаёт ссылку `vless://`
- `./remove_client.sh <имя>` — отозвать доступ
- `./show_clients.sh` — все ссылки
- `./stop_proxy.sh`

### Клиенты
Ссылку импортировать в Happ / v2RayTun (iOS, Android), Hiddify / v2rayN (ПК).

### FAKE_DOMAIN
Сайт должен поддерживать TLS 1.3 + HTTP/2 и не стоять за CDN. Лучше брать сайт, хостящийся у того же провайдера / в той же стране, что и сервер. Задаётся в `settings.env`, после изменения перезапустить `./start_proxy.sh` (ссылки клиентов поменяются).

Порт 443 может быть занят mtg — тогда поменяйте `PORT` у одного из них.
