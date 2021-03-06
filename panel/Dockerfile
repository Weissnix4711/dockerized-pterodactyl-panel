################
## Base Stage ##
################

FROM php:7.4-fpm-alpine as base

ARG panel_ver
ENV PANEL_VER ${panel_ver}

WORKDIR /panel

# Install dependencies
RUN apk add --no-cache --update tini dcron curl supervisor tar unzip \
	libpng-dev libxml2-dev libzip-dev; \
	docker-php-ext-install bcmath; \
	docker-php-ext-install gd; \
	docker-php-ext-install mbstring; \
	docker-php-ext-install pdo; \
	docker-php-ext-install pdo_mysql; \
	docker-php-ext-install tokenizer; \
	docker-php-ext-install xml; \
	docker-php-ext-configure zip --with-libzip=/usr/include; \
	docker-php-ext-install zip;

#################
## Build Stage ##
#################

FROM base as build

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Download files
RUN curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/download/${PANEL_VER}/panel.tar.gz; \
	tar --strip-components=1 -xzvf panel.tar.gz;

# Composer
RUN cp .env.example .env; \
	composer install --no-dev --optimize-autoloader; \
	rm -f .env;

# Storage template
RUN find storage -type d > .storage.template

# Permissions
RUN chmod -R 755 storage/* bootstrap/cache
RUN chown -R www-data:www-data .

#################
## Final Stage ##
#################

FROM base as final

# Copy from build
COPY --from=build --chown=www-data:www-data /panel /panel

VOLUME [ "public/" ]
VOLUME [ "storage/" ]
VOLUME [ "bootstrap/cache" ]

# Cron
RUN echo "* * * * * /usr/local/bin/php /panel/artisan schedule:run >> /dev/null 2>&1" >> /var/spool/cron/crontabs/root

# Supervisor
COPY ./supervisord.conf /etc/supervisord.conf

# Entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]
