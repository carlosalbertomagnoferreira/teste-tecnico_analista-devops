#!/bin/sh
set -e

php -r "file_exists('.env') || copy('.env.example', '.env');"
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

chown -R www-data:www-data database

# Start nginx process
nohup nginx -g "daemon off;" &

# Run the default command
exec "$@"