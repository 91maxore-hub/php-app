FROM php:8.2-fpm

# Installera Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Skapa en icke-root-användare
RUN groupadd -r appuser && useradd -r -g appuser -d /var/www -s /sbin/nologin appuser

# Kopiera applikationens filer
COPY . /var/www/html

# Ändra ägarskap till appuser
RUN chown -R appuser:appuser /var/www/html

# Kopiera Nginx-konfiguration
COPY default.conf /etc/nginx/sites-available/default

# Kopiera PHP-FPM-konfiguration
COPY php-fpm.conf /usr/local/etc/php-fpm.d/zz-appuser.conf

WORKDIR /var/www/html

EXPOSE 80

# Starta php-fpm och nginx
CMD ["bash", "-c", "php-fpm & nginx -g 'daemon off;'"]