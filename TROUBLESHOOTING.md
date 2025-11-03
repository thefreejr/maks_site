# Решение проблем с Docker

## Проблема: curl не может подключиться к порту 80

### Причина
По умолчанию сайт настроен на порт **8080**, а не 80, потому что порт 80 часто занят другими сервисами.

### Решение

#### Вариант 1: Использовать правильный порт
```bash
# Используйте порт 8080 вместо 80
curl http://127.0.0.1:8080

# Или в браузере
http://localhost:8080
```

#### Вариант 2: Проверить статус контейнера
```bash
# Проверить, запущен ли контейнер
docker ps | grep maks_site

# Если контейнер не запущен, запустить его
docker-compose up -d

# Проверить логи, если есть ошибки
docker logs maks_site_nginx
```

#### Вариант 3: Изменить порт на 80 (если порт свободен)
Отредактируйте `docker-compose.yml`:
```yaml
ports:
  - "80:80"  # Измените с "8080:80" на "80:80"
```

Затем перезапустите:
```bash
docker-compose down
docker-compose up -d
```

### Проверка портов
```bash
# Проверить, какой порт слушается
netstat -tuln | grep 8080
# или
ss -tuln | grep 8080

# Проверить, не занят ли порт 80
sudo netstat -tuln | grep :80
sudo ss -tuln | grep :80
```

### Полная диагностика
```bash
# 1. Проверить статус Docker
docker --version
docker ps -a

# 2. Проверить статус контейнера
docker-compose ps

# 3. Проверить логи
docker-compose logs nginx

# 4. Проверить, слушается ли порт
sudo netstat -tuln | grep 8080
```

### Быстрый старт с нуля
```bash
# 1. Создать директорию для логов
mkdir -p logs/nginx

# 2. Собрать образ
docker-compose build

# 3. Запустить контейнер
docker-compose up -d

# 4. Проверить статус
docker-compose ps

# 5. Проверить доступность
curl http://127.0.0.1:8080
```

### Если контейнер не запускается
```bash
# Посмотреть детальные логи
docker-compose logs --tail=50 nginx

# Проверить ошибки сборки
docker-compose build --no-cache

# Удалить и пересоздать контейнер
docker-compose down
docker-compose up -d --build
```

