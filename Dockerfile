FROM debian:buster

############################
## Arguments / Enviroment ##
############################

# ARG php_ver
# ENV PHP_VER ${php_ver} 

# ARG webserver
# ENV WEBSERVER ${webserver}

ARG mysql_db
ARG mysql_user
ARG mysql_password
ARG mysql_root_password
ENV MYSQL_DB ${mysql_db}
ENV MYSQL_USER ${mysql_user}
ENV MYSQL_PASSWORD ${mysql_password}
ENV MYSQL_ROOT_PASSWORD ${mysql_root_password}

##########################
## Install Dependencies ##
##########################

# Update package lists
RUN apt-get update

# General
RUN apt-get install -y curl

# MariaDB
RUN apt-get install -y mariadb-common mariadb-server mariadb-client \
	&& /etc/init.d/mysql start

# PHP7.3
RUN apt-get install -y php7.3 \
	php7.3-cli \
	php7.3-common \
	php7.3-gd \
	php7.3-mysql \
	php7.3-mbstring \
	php7.3-bcmath \
	php7.3-xml \
	php7.3-fpm \
	php7.3-curl \
	php7.3-zip \
	&& /etc/init.d/php7.3-fpm start

# Nginx
RUN apt-get install -y nginx

# Redis
RUN apt-get install -y redis-server \
	&& /etc/init.d/redis-server start

# Composer
RUN curl -sS https://getcomposer.org/installer \
	| php -- --install-dir=/usr/local/bin --filename=composer

# Configure MariaDB
# TODO

# Add mysql user
RUN mysql -u root -p -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD)';" \
	&& mysql -u root -p -e "CREATE DATABASE ${MYSQL_DB};" \
	&& mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;" \
	&& mysql -u root -p -e "FLUSH PRIVILEGES;"

########################
## Panel installation ##
########################

# Download pterodactyl files
RUN mkdir -p /var/www/pterodactyl \
	&& cd /var/www/pterodactyl \
	&& curl -Lo panel.tar.gz "https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz" \
	&& tar --strip-components=1 -x xzvf panel.tar.gz \
	&& chmod -R 755 storage/* bootstrap/cache/

# Composer and key gen
RUN composer install --no-dev --optimize-autoloader \
	&& php artisan key:generate --force

# Configure
RUN echo -e "\
	# Egg author  email
	dev.aldrian@gmail.com\n\
	# Application url
	http://localhost\n\
	# Timezone
	Europe/London\n\
	# Cache Driver
	redis\n\
	# Session Driver
	redis\n\
	# Queue Driver
	redis\n\
	# UI Based Settings Editor
	yes\n\
	# REDIS SETTINGS
	# Redis host
	localhost\n\
	# Redis password
	\n\
	# Redis port
	\n\
	" | php artisan p:environment:setup 2>/dev/null

RUN echo -e "\
	todo\n\
	" | php artisan p:environment:database 2>/dev/null

RUN php artisan p:environment:mail \
	&& php artisan migrate --seed \
	&& php artisan p:user:make

# Set folder permissions
RUN chown -R www-data:www-data *

# Crontab
RUN crontab -l | { cat; echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1"; } | crontab -
