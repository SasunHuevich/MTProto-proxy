### ГЕНЕРАЦИЯ СЕКРЕТА

```bash
echo $(head -c 16 /dev/urandom | xxd -ps)
```
