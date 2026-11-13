#!/usr/bin/env bash
set -euo pipefail

trap 'echo "Installation failed at line ${LINENO}" >&2' ERR

export DEBIAN_FRONTEND=noninteractive

apt-get -o Acquire::Retries=3 update

apt-get -o DPkg::Lock::Timeout=120 install -y \
  apache2 \
  libapache2-mod-php \
  php \
  php-mysql \
  php-curl \
  php-gd \
  php-mbstring \
  php-xml \
  php-zip \
  php-intl \
  mysql-client \
  curl \
  jq \
  unzip \
  ca-certificates

a2enmod rewrite
apache2ctl configtest

systemctl enable apache2
systemctl restart apache2

php --version
mysql --version

curl --fail --silent --show-error \
  --retry 5 \
  --retry-connrefused \
  --retry-delay 2 \
  --output /dev/null \
  http://127.0.0.1/

echo "Web stack installation completed successfully."
