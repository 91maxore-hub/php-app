# PHP-FPM (ingen nginx längre)
FROM php:8.2-fpm

# Skapa användaren 'appuser' (icke-root)
RUN groupadd -r appuser && useradd -r -g appuser appuser

# Kopiera hela din app till rätt mapp
COPY . /var/www/html

# Ge äganderätt till appuser
RUN chown -R appuser:appuser /var/www/html

# Ange arbetsmapp
WORKDIR /var/www/html

# Kör som icke-root
USER appuser

# Exponera porten för PHP-FPM (internt)
EXPOSE 9000

# Starta php-fpm
CMD ["php-fpm", "-F"]