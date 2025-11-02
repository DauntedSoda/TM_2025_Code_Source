FROM php:8.4-apache

WORKDIR /var/www/html

# Cette version installe aussi par defaut des packages recommandes si il y en a: 
RUN apt-get update && apt-get install -y \
    default-mysql-client 

RUN docker-php-ext-install mysqli

## Installer default-mysql-client et nettoyer ensuite pour garder l'image plus petite
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    default-mysql-client \
# && docker-php-ext-install mysqli \
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*