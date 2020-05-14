FROM php:7.3.10-apache-stretch

LABEL maintainer="Christian Pedersen <christian.pedersen@zentura.dk>"
LABEL application="Unofficial Live!Zilla - Docker"

ENV DEBIAN_FRONTEND=noninteractive

ENV LIVEZILLA_VERSION="8.0.1.9"
ENV PACKAGE_URL="https://www.livezilla.net/downloads/pubfiles/livezilla_server_$LIVEZILLA_VERSION.zip"

RUN apt-get update && apt-get --no-install-recommends install -y \
        unzip \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev && \
    docker-php-ext-configure gd \
        --with-freetype-dir=/usr/include/freetype2 \
        --with-png-dir=/usr/include \
        --with-jpeg-dir=/usr/include && \
    rm -rf /var/lib/apt/lists/* && \
    docker-php-ext-install gd mysqli && \
    mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY assets/. /usr/local/bin/

RUN chmod +x /usr/local/bin/livezilla-*

EXPOSE 80 443

VOLUME [ "/var/www/html" ]

ENTRYPOINT [ "livezilla-docker-entrypoint.sh" ]

WORKDIR /var/www/html

CMD [ "apache2-foreground" ]
