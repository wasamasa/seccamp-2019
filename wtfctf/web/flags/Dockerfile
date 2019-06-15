FROM richarvey/nginx-php-fpm

COPY ./src/index.php /var/www/html/index.php
COPY ./flags/* /var/www/html/flags/
COPY ./flag /flag

WORKDIR "/var/www/html"
CMD ["/start.sh"]
