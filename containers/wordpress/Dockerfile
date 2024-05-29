#!BuildTag: wordpress:latest

FROM registry.suse.com/bci/php-apache:8

RUN zypper --non-interactive in php8-mysql

RUN curl --output-dir /tmp -O -L https://wordpress.org/latest.tar.gz

RUN tar --strip-components=1 -C /srv/www/htdocs -xvf /tmp/latest.tar.gz

COPY wp-config.php /srv/www/htdocs/
