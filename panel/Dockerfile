FROM php:7.3-fpm-buster

###############################
## Dependencies / extensions ##
###############################

# Download easy extensions install script
ADD https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions /usr/local/bin/
RUN chmod uga+x /usr/local/bin/install-php-extensions && sync

# General dependencies
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
	&& apt-get install -y curl git zip unzip

# PHP Extensions
RUN install-php-extensions \
	gd \
	mysqli \
	pdo_mysql \
#	mbstring \
#	tokenizer \
	bcmath \
#	xml \
#	curl \
	zip

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

####################
## config / setup ##
####################

# mkdir
RUN mkdir -p /var/www/pterodactyl

# Add setup script
ADD setup.sh /setup.sh
RUN chmod +x /setup.sh
