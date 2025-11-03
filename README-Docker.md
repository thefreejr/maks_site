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

## Быстрый старт

### Windows (PowerShell)
```powershell
# Создайте директорию для логов
.\init-logs.ps1

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

# Соберите образ
docker-compose build

# Запустите контейнер
docker-compose up -d
```

3. Откройте в браузере: http://localhost:8080

**Примечание:** Если порт 8080 занят, измените его в `docker-compose.yml` на другой порт (например, 8081, 3000 и т.д.)

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

