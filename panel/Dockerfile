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

# Install yarn
RUN apk add yarn

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

# Yarn stuff
RUN yarn install --production; \
	yarn add cross-env; \
	yarn run build:production; \
	rm -rf node_modules;

#################
## Final Stage ##
#################

FROM base as final

# Copy from build
COPY --from=build /panel /panel

# Entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/sbin/tini", "--", "/entrypoint.sh" ]
