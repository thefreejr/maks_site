# Docker развертывание сайта на nginx

## Проверка занятых портов

Если порт 8080 занят, проверьте и выберите свободный:

### Windows (PowerShell)
```powershell
# Проверить, занят ли порт 8080
netstat -ano | findstr :8080

# Проверить все занятые порты
netstat -ano | findstr LISTENING
```

### Linux/Mac
```bash
# Проверить, занят ли порт 8080
lsof -i :8080
# или
ss -tulpn | grep :8080
```

### Изменение порта

Откройте `docker-compose.yml` и измените строку:
```yaml
ports:
  - "8080:80"  # Измените 8080 на свободный порт (например, 3000, 8081, 9000)
```

## Настройка HTTPS

### Быстрая настройка (самоподписанный сертификат для разработки)

#### Windows (PowerShell)
```powershell
# Генерация самоподписанного сертификата
# Рекомендуется использовать Git Bash или WSL для запуска generate-ssl.sh
# Или установите OpenSSL для Windows и используйте команды ниже

# Установите OpenSSL (через Chocolatey: choco install openssl)
# Затем создайте директорию и сертификаты:
mkdir ssl
openssl genrsa -out ssl/key.pem 2048
openssl req -new -x509 -key ssl/key.pem -out ssl/cert.pem -days 365 -subj "/CN=localhost"
```

#### Linux/Mac
```bash
# Создайте SSL сертификаты
chmod +x generate-ssl.sh
./generate-ssl.sh localhost

# Или вручную:
mkdir -p ssl
openssl genrsa -out ssl/key.pem 2048
openssl req -new -x509 -key ssl/key.pem -out ssl/cert.pem -days 365 -subj "/CN=localhost"
```

### Использование Let's Encrypt для продакшена

1. **Установите certbot:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install certbot

# Создайте сертификат
sudo certbot certonly --standalone -d yourdomain.com
```

2. **Скопируйте сертификаты в директорию ssl:**
```bash
sudo cp /etc/letsencrypt/live/yourdomain.com/fullchain.pem ssl/cert.pem
sudo cp /etc/letsencrypt/live/yourdomain.com/privkey.pem ssl/key.pem
sudo chmod 644 ssl/cert.pem
sudo chmod 600 ssl/key.pem
```

3. **Обновите nginx-site.conf:**
   - Раскомментируйте строки OCSP stapling для продакшен сертификатов
   - Измените `server_name _;` на `server_name yourdomain.com;`

4. **Настройте автоматическое обновление сертификатов:**
```bash
# Добавьте в crontab (crontab -e)
0 0 * * * certbot renew --quiet && docker-compose restart nginx
```

## Быстрый старт

### Windows (PowerShell)
```powershell
# Создайте директорию для логов
.\init-logs.ps1

# Создайте SSL сертификаты (см. раздел "Настройка HTTPS")
# mkdir ssl
# ... (команды для создания сертификатов)

# Соберите образ
docker-compose build

# Запустите контейнер
docker-compose up -d
```

### Linux/Mac
```bash
# Создайте директорию для логов
chmod +x init-logs.sh
./init-logs.sh

# Создайте SSL сертификаты (см. раздел "Настройка HTTPS")
chmod +x generate-ssl.sh
./generate-ssl.sh localhost

# Соберите образ
docker-compose build

# Запустите контейнер
docker-compose up -d
```

3. Откройте в браузере:
   - **HTTPS:** https://localhost (или ваш домен)
   - **HTTP:** http://localhost (автоматически перенаправит на HTTPS)

**Важно:** При использовании самоподписанного сертификата браузер покажет предупреждение о безопасности. Это нормально для разработки. Для продакшена используйте Let's Encrypt.

```bash
# Проверка доступности HTTPS
curl -k https://127.0.0.1

# Проверка редиректа с HTTP на HTTPS
curl -I http://127.0.0.1

# Или в браузере
https://localhost
```

**Примечание:** Флаг `-k` в curl игнорирует проверку сертификата (для самоподписанных сертификатов)

**Примечание:** 
- Сайт работает по HTTPS (порт 443)
- HTTP (порт 80) автоматически перенаправляет на HTTPS
- Если порт 443 занят, измените его в `docker-compose.yml` на другой порт (например, 8443:443)

## Управление логами

Логи nginx сохраняются на хост-машине в директории `./logs/nginx/`:
- `access.log` - логи доступа
- `error.log` - логи ошибок

Просмотр логов:
```bash
# Логи доступа
tail -f logs/nginx/access.log

# Логи ошибок
tail -f logs/nginx/error.log

# Логи контейнера через Docker
docker-compose logs -f nginx
```

## Оптимизации

### Производительность
- ✅ Gzip компрессия для уменьшения размера передаваемых данных
- ✅ Кэширование статических файлов на 1 год
- ✅ Кэширование HTML файлов на 1 час
- ✅ Оптимизированные worker processes
- ✅ Epoll для Linux систем
- ✅ Open file cache для быстрого доступа к файлам
- ✅ Sendfile для эффективной передачи файлов

### Безопасность
- ✅ HTTPS с поддержкой TLS 1.2 и 1.3
- ✅ Автоматический редирект HTTP → HTTPS
- ✅ HSTS (HTTP Strict Transport Security)
- ✅ Современные SSL шифры
- ✅ Отключены server tokens
- ✅ Заголовки безопасности (X-Frame-Options, X-Content-Type-Options, etc.)
- ✅ Запрещен доступ к скрытым файлам

### Ресурсы
- ✅ Ограничения памяти и CPU
- ✅ Healthcheck для мониторинга
- ✅ Автоматический перезапуск контейнера

## Команды управления

```bash
# Остановка
docker-compose down

# Перезапуск
docker-compose restart

# Пересборка после изменений
docker-compose up -d --build

# Просмотр статуса
docker-compose ps

# Просмотр использования ресурсов
docker stats maks_site_nginx

# Остановка и удаление контейнера с логами
docker-compose down -v
```

### Ограничение ресурсов при запуске

Для ограничения использования ресурсов используйте параметры Docker:

```bash
# Ограничение памяти и CPU
docker run -d --name maks_site_nginx \
  --memory="256m" --cpus="1.0" \
  -p 8080:80 \
  maks_site_nginx
```

## Ротация логов

Рекомендуется настроить ротацию логов nginx на хост-машине:

```bash
# Установите logrotate (если еще не установлен)
sudo apt-get install logrotate

# Создайте конфигурацию ротации
sudo nano /etc/logrotate.d/nginx-docker
```

Добавьте:
```
/path/to/maks_site/logs/nginx/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0644 root root
    sharedscripts
    postrotate
        docker exec maks_site_nginx nginx -s reopen
    endscript
}
```

## Мониторинг

Healthcheck проверяет доступность сайта каждые 30 секунд.

Проверка статуса:
```bash
docker inspect --format='{{.State.Health.Status}}' maks_site_nginx
```

