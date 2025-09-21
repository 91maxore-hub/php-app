# Använd officiell PHP 8.2 FPM image som bas (PHP med FastCGI Process Manager)
FROM php:8.2-fpm

# Uppdatera paketlistan och installera Nginx webbserver
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Ta bort standardfiler i Nginx webbroot för att undvika att visa standardstartsidan
RUN rm -rf /var/www/html/*

# Kopiera applikationens filer från din dator till containerns webbrot
COPY . /var/www/html

# Byt arbetskatalog till webbrot, där index.php ligger
WORKDIR /var/www/html

# Kopiera din egen Nginx-konfiguration till standardplats
COPY default.conf /etc/nginx/sites-available/default

# Skapa en icke-root användare och grupp med UID och GID 1000
RUN groupadd -g 1000 appuser && \
    useradd -u 1000 -g appuser -m appuser && \
    chown -R appuser:appuser /var/www/html

# Byt till icke-root användaren
USER appuser

# Exponera port 80 för webbtrafik utanför containern
EXPOSE 80

# Starta php-fpm i bakgrunden och nginx i förgrunden
CMD ["bash", "-c", "php-fpm -F -R & nginx -g 'daemon off;'"]