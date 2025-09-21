#!/bin/bash

# Starta PHP-FPM i bakgrunden
php-fpm &

# Starta nginx i förgrunden (detta håller containern igång)
nginx -g "daemon off;"