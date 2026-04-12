# Telegram MTProto Proxy (Docker)

Простой способ поднять свой прокси для Telegram с помощью Docker.

### 1. Сгенерировать секрет

```bash
echo $(head -c 16 /dev/urandom | xxd -ps)
```

### 2. Вставить секрет в docker-compose.yaml

```yaml
SECRET: <output from step 1 here>
```

### 3. Запустить сервис 

```bash
docker compose up -d --build
```

### 4. Подключиться

В тг указать IP сервера, порт из docker-compose и сгенерированный секрет.