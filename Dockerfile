# syntax=docker/dockerfile:1

FROM composer:2.8.12@sha256:5248900ab8b5f7f880c2d62180e40960cd87f60149ec9a1abfd62ac72a02577c AS builder

ARG LARAVEL_VERSION=12.0.11
ENV COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /app

RUN composer create-project \
        --prefer-dist \
        --no-dev \
        --no-interaction \
        --no-progress \
        "laravel/laravel:${LARAVEL_VERSION}" . \
    && composer audit --locked --no-dev \
    && composer clear-cache \
    && rm -f .env

FROM php:8.4-fpm-alpine3.22@sha256:e0f1ffe8bd43a137facdccdcac41cabdfc23e8d0fdd0665916a062f16e2f4058 AS runtime

ENV APP_ENV=production \
    APP_DEBUG=false \
    LOG_CHANNEL=stderr \
    CACHE_STORE=array \
    SESSION_DRIVER=cookie \
    QUEUE_CONNECTION=sync

# As versões exatas são fornecidas pelo repositório da versão fixa do Alpine.
# hadolint ignore=DL3018
RUN apk update && apk upgrade openssl c-ares curl libcurl \
    && apk add --no-cache nginx \
    && cp "${PHP_INI_DIR}/php.ini-production" "${PHP_INI_DIR}/php.ini" \
    && install -d -o www-data -g www-data \
        /var/cache/nginx/client_temp \
        /var/cache/nginx/fastcgi_temp \
        /var/cache/nginx/proxy_temp \
        /var/cache/nginx/scgi_temp \
        /var/cache/nginx/uwsgi_temp \
        && rm -rf /var/cache/apk/*

COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/php-fpm/app.ini "${PHP_INI_DIR}/conf.d/99-app.ini"
COPY docker/php-fpm/www.conf /usr/local/etc/php-fpm.d/zz-app.conf

WORKDIR /var/www/html

COPY --chown=www-data:www-data --from=builder /app /var/www/html
COPY --chown=www-data:www-data info.php /var/www/html/public/info.php
COPY --chmod=755 docker/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN nginx -e /dev/stderr -t \
    && php-fpm --test

USER 82:82

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD ["wget", "--quiet", "--spider", "http://127.0.0.1:8080/healthz"]

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "--nodaemonize"]
