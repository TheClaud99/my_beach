FROM ubuntu:18.04
### Install requirements ###
ENV TZ=Europe/Rome
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get autoclean && apt-get clean
#RUN apt-get -y update
#RUN apt-get install -y software-properties-common python-software-properties
#RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-get -y update && apt-get -y upgrade --fix-missing
RUN apt-get install -yq --no-install-recommends \
    apache2 \
    curl \
    php7.2 \
    libapache2-mod-php7.2 \
    php7.2-mbstring \
    php7.2-xml \
    php7.2-zip \
    php7.2-gettext \
    php7.2-gmp \
    php7.2-gd \
    php7.2-mysql \
    php7.2-curl \
    php-pear
RUN apt-get -y install git-core zip unzip
RUN apt-get -y install supervisor
RUN apt-get autoclean && apt-get clean
### Apache configuration ###
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP staff
RUN usermod -u 1000 www-data
RUN chown -R www-data:staff /var/www
RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/run/sshd /var/log/supervisor
COPY config/apache-vh.conf /etc/apache2/sites-available/laravel.conf
RUN a2dissite 000-default
RUN a2ensite laravel
RUN a2enmod rewrite
RUN a2enmod headers
RUN chown -R 1000:www-data /var/www/html/
RUN update-alternatives --set php /usr/bin/php7.2
### Composer ###
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
### Starting application ###
COPY config/docker-supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord"]