#!/bin/bash
# Скрипт для проверки статуса Docker контейнера

echo "=== Проверка Docker ==="
docker --version

echo ""
echo "=== Проверка статуса контейнера ==="
docker ps -a | grep maks_site || echo "Контейнер не найден"

echo ""
echo "=== Проверка портов ==="
netstat -tuln | grep 8080 || ss -tuln | grep 8080 || echo "Порт 8080 не слушается"

echo ""
echo "=== Проверка логов (последние 20 строк) ==="
if docker ps -a | grep -q maks_site; then
    docker logs maks_site_nginx --tail 20
else
    echo "Контейнер не запущен"
fi

