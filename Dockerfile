# Используем легкий alpine образ nginx
FROM nginx:alpine

# Устанавливаем wget для healthcheck
RUN apk add --no-cache wget

# Удаляем дефолтную конфигурацию nginx
RUN rm -rf /etc/nginx/conf.d/default.conf

# Копируем оптимизированную конфигурацию nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY nginx-site.conf /etc/nginx/conf.d/default.conf

# Копируем статические файлы сайта
COPY LP/ /usr/share/nginx/html/

# Создаем директории для логов
RUN mkdir -p /var/log/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chmod -R 755 /var/log/nginx

# Открываем порты 80 (HTTP) и 443 (HTTPS)
EXPOSE 80 443

# Используем healthcheck для мониторинга (проверяем HTTPS)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider --no-check-certificate https://localhost/ || exit 1

# Запускаем nginx
CMD ["nginx", "-g", "daemon off;"]

