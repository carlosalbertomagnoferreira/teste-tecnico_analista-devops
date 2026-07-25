#!/bin/sh
set -eu

if [ "${1:-}" = "php-fpm" ]; then
  if [ -z "${APP_KEY:-}" ]; then
    echo >&2 "Erro: defina APP_KEY em tempo de execução (por variável ou secret)."
    echo >&2 "Gere uma chave com: docker run --rm --entrypoint php <imagem> artisan key:generate --show"
    exit 1
  fi

  mkdir -p \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs

  nginx -e /dev/stderr -t
  nginx -e /dev/stderr
fi

exec "$@"
