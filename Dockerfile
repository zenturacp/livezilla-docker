FROM php:7.3.10-apache-stretch

LABEL maintainer="Christian Pedersen <christian.pedersen@zentura.dk>"
LABEL application="LiveZilla - Docker"

ENV PACKAGE_URL="https://www.livezilla.net/downloads/pubfiles/livezilla_server_8.0.1.2.zip"
ENV LIVEZILLA_VERSION="8.0.1.2"

RUN apt-get update && \
 apt-get --no-install-recommends -y install nano unzip libpng-dev && \
 rm -rf /var/lib/apt/lists/* && \
 docker-php-ext-install gd mysqli && \
 mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

COPY assets/. /usr/local/bin/

RUN chmod +x /usr/local/bin/livezilla-*

EXPOSE 80 443

ENTRYPOINT [ "livezilla-docker-entrypoint.sh" ]

WORKDIR /var/www/html

CMD [ "apache2-foreground" ]
