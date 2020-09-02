#!/bin/bash

echo "============================================="
echo "==Quick setup script for pterodactyl panel =="
echo "============================================="
echo ""
echo "Do not run this file on your host system, only in container."
echo "Running setup script multiple times may give unusual results."

echo ""
echo "Do you want to continue [y/n]: "
read CONFIRM_PROCEED
if [[ ! "$CONFIRM_PROCEED" =~ [Yy] ]]; then
  echo "quit"
  exit
fi

cd /var/www/pterodactyl

echo ""

echo "download files"
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/v0.7.18/panel.tar.gz
tar --strip-components=1 -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

echo "copy example .env"
cp .env.example .env

echo "composer install"
composer install --no-dev --optimize-autoloader

echo "gen key"
php artisan key:generate --force
echo "setup"
php artisan p:environment:setup
echo "database"
php artisan p:environment:database
echo "smtp"
php artisan p:environment:mail

echo "database - this may take some time"
php artisan migrate --seed

echo "add first user"
php artisan p:user:make

echo "setting permissions"
chown -R www-data:www-data *
