#!BuildTag: wordpress:latest

FROM registry.suse.com/bci/php-apache:8

RUN zypper --non-interactive up 

RUN zypper --non-interactive in php8-mysql

RUN curl --output-dir /tmp -O -L https://wordpress.org/latest.tar.gz

RUN tar --strip-components=1 -C /srv/www/htdocs -xvf /tmp/latest.tar.gz

# uncomment to create a broken container
# RUN chmod -x /usr/local/bin/apache2*

COPY wp-config.php /srv/www/htdocs/
