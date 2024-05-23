FROM registry.suse.com/bci/php-apache:8

RUN zypper --non-interactive in unzip php8-mysql

RUN cd /tmp && curl -O -L https://wordpress.org/latest.zip

RUN unzip /tmp/latest.zip -d /srv/www/htdocs/

COPY wp-config.php /srv/www/htdocs/