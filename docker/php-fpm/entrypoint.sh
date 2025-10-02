#!/bin/sh
set -e

# Start Nginx
nohup nginx -g "daemon off;" > /dev/null &

php artisan key:generate

# Run Laravel migrations
# -----------------------------------------------------------
# Ensure the database schema is up to date.
# -----------------------------------------------------------
php artisan migrate --force

# Clear and cache configurations
# -----------------------------------------------------------
# Improves performance by caching config and routes.
# -----------------------------------------------------------
php artisan config:cache
php artisan route:cache

# Run the default command
# php-fpm

exec "$@"