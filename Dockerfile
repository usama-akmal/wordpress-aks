FROM wordpress@sha256:8b64037bb2a3bdc41bebccb165f20ad5e4c786b684ae4a2bd5981f98aa1eb107

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Bake application code into the image before dropping privileges.
RUN set -eux; \
    cp -a /usr/src/wordpress/. /var/www/html/; \
    chown -R root:root /var/www/html; \
    find /var/www/html -type d -exec chmod 755 {} +; \
    find /var/www/html -type f -exec chmod 644 {} +; \
    mkdir -p /var/www/html/wp-content/uploads \
        /var/run/apache2 /var/lock/apache2 /var/log/apache2; \
    chown -R www-data:www-data /var/www/html/wp-content/uploads \
        /var/run/apache2 /var/lock/apache2 /var/log/apache2; \
    sed -i 's/^Listen 80$/Listen 8080/' /etc/apache2/ports.conf

COPY docker/apache-wordpress.conf /etc/apache2/sites-available/000-default.conf

COPY --chown=0:33 --chmod=640 docker/wp-config.php /var/www/html/wp-config.php

WORKDIR /var/www/html

COPY --chmod=0644 docker/demo-release.txt /var/www/html/demo-release.txt

# Debian's www-data identity, expressed numerically for Kubernetes validation.
USER 33:33

EXPOSE 8080

# Application code is already present; runtime config will be supplied separately.
ENTRYPOINT []
CMD ["apache2-foreground"]
