#!/bin/bash

# Скрипт для генерации самоподписанного SSL сертификата
# Использование: ./generate-ssl.sh [доменное_имя]

DOMAIN="${1:-localhost}"
SSL_DIR="./ssl"

# Создаем директорию для сертификатов
mkdir -p "$SSL_DIR"

# Генерируем приватный ключ
openssl genrsa -out "$SSL_DIR/key.pem" 2048

# Генерируем сертификат
openssl req -new -x509 -key "$SSL_DIR/key.pem" -out "$SSL_DIR/cert.pem" -days 365 \
    -subj "/C=RU/ST=State/L=City/O=Organization/CN=$DOMAIN"

# Устанавливаем правильные права доступа
chmod 600 "$SSL_DIR/key.pem"
chmod 644 "$SSL_DIR/cert.pem"

echo "SSL сертификаты успешно созданы в директории $SSL_DIR"
echo "Сертификат действителен для домена: $DOMAIN"
echo ""
echo "Для использования в браузере вам нужно будет добавить исключение безопасности,"
echo "так как это самоподписанный сертификат."

