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
# ARG mysql_root_password
ENV MYSQL_DB ${mysql_db}
ENV MYSQL_USER ${mysql_user}
ENV MYSQL_PASSWORD ${mysql_password}
# ENV MYSQL_ROOT_PASSWORD ${mysql_root_password}

##########################
## Install Dependencies ##
##########################

# Update package lists
RUN apt update

# MariaDB
RUN apt install -y mariadb-common mariadb-server mariadb-client \
	&& /etc/init.d/mysql start

# PHP7.3
RUN apt install -y php7.3 \
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
RUN apt install -y nginx

# Redis
RUN apt install -y redis-server \
	&& /etc/init.d/redis-server start

# Composer
RUN curl -sS https://getcomposer.org/installer \
	| php -- --install-dir=/usr/local/bin --filename=composer

# Configure MariaDB
RUN echo -e "\
	# Current root pass
	\n\n\
	# Set root pass?
	Y\n\
	# Your root pass
	mypassword\n\
	# Your root pass
	mypassword\n\
	# Remove anonymous users?
	Y\n\
	# Disallow root login remotely?
	Y\n\
	# Remove test database and access to it?
	Y\n\	
	# Reload privilege tables now?
	Y\n\
	" | mysql_secure_installation 2>/dev/null

# Add mysql user
RUN mysql -u root -p -e "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD)';" \
	&& mysql -u root -p -e "CREATE DATABASE ${MYSQL_DB};" \
	&& mysql -u root -p -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO '${MYSQL_USER}'@'%' WITH GRANT OPTION;" \
	&& mysql -u root -p -e "FLUSH PRIVILEGES;"

########################
## Panel installation ##
########################

# todo
