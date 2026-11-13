#!/usr/bin/env bash
set -euo pipefail

trap 'echo "WordPress installation failed at line ${LINENO}" >&2' ERR

WORDPRESS_VERSION="7.1.4"
WORDPRESS_SHA1="b552c39cd95d89895b4e7a55af53a03687aff4f6"

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "$WORK_DIR"' EXIT

curl --fail --silent --show-error \
  --location \
  --retry 3 \
  --output "$WORK_DIR/wordpress.zip" \
  "https://downloads.wordpress.org/release/wordpress-${WORDPRESS_VERSION}.zip"

printf '%s  %s\n' \
  "$WORDPRESS_SHA1" \
  "$WORK_DIR/wordpress.zip" |
  sha1sum --check -

unzip -q "$WORK_DIR/wordpress.zip" -d "$WORK_DIR"

install -d -m 755 /var/www/wordpress
cp -a "$WORK_DIR/wordpress/." /var/www/wordpress/

chown -R root:www-data /var/www/wordpress
find /var/www/wordpress -type d -exec chmod 755 {} +
find /var/www/wordpress -type f -exec chmod 644 {} +

install -d \
  -o www-data \
  -g www-data \
  -m 755 \
  /var/www/wordpress/wp-content/uploads

test -f /var/www/wordpress/wp-load.php

echo "WordPress ${WORDPRESS_VERSION} files installed successfully."
