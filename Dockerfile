# Stage 1: de instalação dos componentes com o composer
FROM composer:2 AS vendor

# Definindo diretorio de trabalho para contrução da imagem
WORKDIR /tmp/

COPY composer.json composer.json
COPY composer.lock composer.lock

RUN composer install \
    --ignore-platform-reqs \
    --no-interaction \
    --no-plugins \
    --no-scripts \
    --prefer-dist \
    --no-dev \
    --optimize-autoloader

# Stage 2: Contrução da imagem com os arquivos do stage 1
FROM php:8.3-fpm-alpine3.22

# Definindo diretorio de trabalho para contrução da imagem
WORKDIR /var/www/html

# Copiando arquivos do repositorio para a imagem
COPY . .

# Copiando arquivos do stage 1
COPY --from=vendor /tmp/vendor/ ./vendor/

# Download e instalação do php-fpm health check script
RUN curl -o /usr/local/bin/php-fpm-healthcheck \
https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
&& chmod +x /usr/local/bin/php-fpm-healthcheck
RUN apk add --no-cache fcgi
RUN set -xe && echo "pm.status_path = /status" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Transferindo arquivo de inicialização
COPY ./docker/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Configuração de permissões
RUN chown -R www-data:www-data /var/www

# Definindo usuario de execução
USER www-data

# Porta de acesso ao php-fpm
EXPOSE 9000

# healthcheck do php-fpm, verificando o serviço a cada 30 segundos
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD php-fpm-healthcheck || exit 1

# executa o php-fpm na inicialização do container
CMD ["php-fpm"]