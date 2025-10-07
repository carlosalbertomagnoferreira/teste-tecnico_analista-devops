# Stage 1: Criação do projeto com composer
FROM composer:2.8.12 AS builder

# Defindo diretorio de trabalho de instalação
WORKDIR /app

# Criando projeto Laravel
RUN composer create-project --prefer-dist laravel/laravel myapp --no-dev

# Stage 2: Usando image base para aplicação 
FROM php:8.4-fpm-alpine3.22

# Update de pacotes, correção de vulnerabilidades
RUN apk update && apk upgrade

# Instalando Nginx, fcgi e copiando arquivo de configuração
RUN apk add --no-cache \
    fcgi=2.4.6-r0 \
    nginx=1.28.0-r3 && \
    rm -rf /var/cache/apk/*
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Download e instalação do php-fpm-healthcheck script
RUN curl -o /usr/local/bin/php-fpm-healthcheck \
https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
&& chmod +x /usr/local/bin/php-fpm-healthcheck
RUN set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Definindo diretorio de trabalho de execução
WORKDIR /var/www/html

# Copiando arquivos gerados no stage 1
COPY --chown=www-data --from=builder /app/myapp /var/www/html

# Copiando arquivo info.php
COPY --chown=www-data info.php /var/www/html/public/info.php

# Transferindo arquivo de inicialização
COPY ./docker/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh


# Porta de acesso ao php-fpm
EXPOSE 80

# healthcheck do php-fpm, verificando o serviço a cada 30 segundos
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD php-fpm-healthcheck || exit 1

# Executa o php-fpm apos script da inicialização
CMD ["php-fpm"]

# Script de inicialização
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]