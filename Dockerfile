FROM php:7.3.10-apache-stretch

LABEL maintainer="Christian Pedersen <christian.pedersen@zentura.dk>"
LABEL application="Unofficial Live!Zilla - Docker"

ENV PACKAGE_URL="https://www.livezilla.net/downloads/pubfiles/livezilla_server_8.0.1.2.zip"
ENV LIVEZILLA_VERSION="8.0.1.2"

RUN apt-get update && apt-get --no-install-recommends install -y \
        nano \
        unzip \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev && \
    docker-php-ext-configure gd \
        --enable-gd-native-ttf \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include && \
    docker-php-ext-install gd && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install gd mysqli && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY assets/. /usr/local/bin/

RUN chmod +x /usr/local/bin/livezilla-*

EXPOSE 80 443

ENTRYPOINT [ "livezilla-docker-entrypoint.sh" ]

WORKDIR /var/www/html

CMD [ "apache2-foreground" ]
