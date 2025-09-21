# PHP med FPM
FROM php:8.2-fpm

# Skapa en icke-root användare "appuser"
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Kopiera appen till webbroot
COPY . /var/www/html

# Ändra ägarskap för rättigheter
RUN chown -R appuser:appuser /var/www/html

# Ange arbetskatalog
WORKDIR /var/www/html

# Byt användare
USER appuser

# Exponera PHP-FPM port
EXPOSE 9000

# Starta PHP-FPM i förgrunden
CMD ["php-fpm", "-F"]