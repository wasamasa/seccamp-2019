FROM richarvey/nginx-php-fpm

RUN rm /var/www/html/index.php
COPY ./src/index.html /var/www/html/
COPY ./src/query.php /var/www/html/
COPY ./src/pages/* /var/www/html/pages/
COPY ./flag /flag

WORKDIR "/var/www/html"
CMD ["/start.sh"]
