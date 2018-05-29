FROM ubuntu:16.04

# default dev because docker-compose build can not pass env variables and default is used
ARG ENV=dev

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    LANGUAGE="en_US.UTF-8" \
    TERM="xterm" \
    DEBIAN_FRONTEND="noninteractive"

EXPOSE 80
WORKDIR /app

RUN apt-get update -q && \
    apt-get install -qy software-properties-common language-pack-en-base wget && \
    export LC_ALL=en_US.UTF-8 && \
    export LANG=en_US.UTF-8 && \
    # php
    add-apt-repository ppa:ondrej/php && \
    apt-get update -q

RUN apt-get install --no-install-recommends -qy \
        ca-certificates \
        curl \
        supervisor \
        nginx

RUN apt-get install --no-install-recommends -qy \
        php7.1 \
        php7.1-common \
        php7.1-curl \
        php7.1-fpm \
        php7.1-xml \
        php7.1-zip \
        php7.1-intl \
        php7.1-json \
        php7.1-iconv \
        php7.1-mcrypt \
        php7.1-cli \
        php7.1-dom \
        php7.1-mbstring

RUN mkdir /run/php

RUN cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && echo "Europe/Berlin" > /etc/timezone

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    mkdir -p /root/.composer

RUN mkdir -p /app/.git/hooks && \
    mkdir -p /app/var/cache && \
    mkdir -p /app/var/log && \
    mkdir -p /app/var/session && \
    chmod -R 0777 /app/var/cache && \
    chmod -R 0777 /app/var/log && \
    chmod -R 0777 /app/var/session

### Configure app
COPY docker/supervisord.conf /etc/supervisor/conf.d/
COPY docker/pool.conf        /etc/php/7.1/fpm/pool.d/www.conf
COPY docker/php-cli.ini      /etc/php/7.1/cli/conf.d/50-setting.ini
COPY docker/php-fpm.ini      /etc/php/7.1/fpm/conf.d/50-setting.ini
COPY docker/nginx.conf       /etc/nginx/nginx.conf

### Install composer
COPY composer.json .
COPY composer.lock .
COPY .env .
RUN SYMFONY_ENV=prod composer install --no-scripts --no-interaction

### Copy PROD code
COPY assets                         /app/assets/
COPY bin                            /app/bin/
COPY config                         /app/config/
COPY public                         /app/public/
COPY src                            /app/src/
COPY templates                      /app/templates/
COPY translations                   /app/translations/

### Cleanup
RUN apt-get clean
RUN rm -rf .git /app/var/cache/* /tmp/* /var/tmp/* /var/lib/apt/lists/*
RUN chown -R www-data:www-data /app

RUN service php7.1-fpm restart
RUN usermod -u 1000 www-data

CMD ["supervisord"]

