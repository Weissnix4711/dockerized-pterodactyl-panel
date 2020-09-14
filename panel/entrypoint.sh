#!/bin/sh

# This script is ran on container start.
#
# It initialises various things, including:
# some basic file / dir cleanup,
# first time db setup,
# crontab configuration,
# and more.

echo "################################"
echo "## STARTING ENTRYPOINT SCRIPT ##"
echo "################################"

# Ensure correct dir
cd /panel

# Create needed dirs if not exist
echo -e "\nAttempting to create storage directory"
mkdir ./storage
cat .storage.template | while read line; do
    mkdir -p "/panel/${line}"
    echo "created ${line}"
done

# Set permissions for storage/framework
chmod -R 775 storage/framework
chown -R www-data:www-data storage/

# Check for config file
if [ ! -s appkey.env ]; then
    echo ""
    echo "######################"
    echo "## first time setup ##"
    echo "######################"
    echo ""
    echo "Initiating first time setup, as appkey.env is empty."
    sleep 1

    echo -e "\nGenerating appkey.env file"
    touch ptero.env
    echo "# Do not use the .env file!" > /panel/appkey.env
    echo "# Use environment variables instead!" >> /panel/appkey.env
    echo "# " >> /panel/appkey.env
    echo "# This file is automatically generated and contains the app key," >> /panel/appkey.env
    echo "# used to encrypt sensitive information." >> /panel/appkey.env
    echo "" >> /panel/appkey.env
    echo "APP_KEY=SomeRandomString3232RandomString" >> /panel/appkey.env

    echo -e "\nMaking symlink"
    sleep 1
    ln -s /panel/appkey.env .env

    echo -e "\nGenerating key..."
    sleep 1
    php artisan key:generate --force --no-interaction

    echo -e "\nCreating & seeding database..."
    sleep 1
    php artisan migrate --force
    php artisan db:seed --force

    echo -e "\nCreating first user..."
    sleep 1
    php artisan p:user:make --email=${FU_EMAIL} --username=${FU_USERNAME} --name-first=${FU_NAME_FIRST} --name-last=${FU_NAME_LAST} --password=${FU_PASSWORD} --admin=${FU_ADMIN}

    # Display errors
    echo "php_flag[display_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf
    echo "php_admin_value[error_log] = /var/log/fpm-php.www.log" >> /usr/local/etc/php-fpm.d/www.conf
    echo "php_admin_flag[log_errors] = on" >> /usr/local/etc/php-fpm.d/www.conf

    echo -e "\n## FIRST TIME SETUP DONE! ##"
fi

echo -e "\n## INITIALISATION IS FINISHED! ##"

echo ""
echo "####################"
echo "## STARTING STUFF ##"
echo "####################"

echo -e "\nWaiting for database..."
until nc -z -v -w30 ${DB_HOST} ${DB_PORT}; do
    sleep 5
    echo "Connection timeout :("
done

exec "$@"
