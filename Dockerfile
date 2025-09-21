FROM php:8.2-fpm

# Installera Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Skapa icke-root-användare
RUN groupadd -r appuser && useradd -r -g appuser -d /var/www -s /sbin/nologin appuser

# Kopiera appen
COPY . /var/www/html

# Ge rättigheter
RUN chown -R appuser:appuser /var/www/html

# Kör som appuser
USER appuser

# Arbeta från rätt mapp
WORKDIR /var/www/html

# Kopiera Nginx-konfiguration
COPY default.conf /etc/nginx/sites-available/default

EXPOSE 80

# Starta både php-fpm och nginx
CMD ["bash", "-c", "php-fpm & nginx -g 'daemon off;'"]