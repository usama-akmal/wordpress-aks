<?php
// Configuration code only. Secret values are supplied through mounted files.

$readSecret = static function (string $variable, string $defaultPath): string {
    $path = getenv($variable) ?: $defaultPath;
    if (!is_readable($path)) {
        throw new RuntimeException('A required runtime secret file is unavailable.');
    }
    $value = file_get_contents($path);
    if ($value === false || $value === '') {
        throw new RuntimeException('A required runtime secret is empty.');
    }
    return $value;
};

$dbHost = getenv('WORDPRESS_DB_HOST');
if ($dbHost === false || $dbHost === '') {
    throw new RuntimeException('WORDPRESS_DB_HOST must be configured.');
}

define('DB_HOST', $dbHost);
define('DB_NAME', getenv('WORDPRESS_DB_NAME') ?: 'wordpress');
define('DB_USER', getenv('WORDPRESS_DB_USER') ?: 'wpapp');
define('DB_PASSWORD', $readSecret(
    'WORDPRESS_DB_PASSWORD_FILE',
    '/run/secrets/wordpress-db-password'
));
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

$dbSsl = filter_var(
    getenv('WORDPRESS_DB_SSL') ?: 'true',
    FILTER_VALIDATE_BOOLEAN,
    FILTER_NULL_ON_FAILURE
);
if ($dbSsl === null) {
    throw new RuntimeException('WORDPRESS_DB_SSL must be true or false.');
}
define('MYSQL_CLIENT_FLAGS', $dbSsl ? MYSQLI_CLIENT_SSL : 0);

$salts = json_decode(
    $readSecret('WORDPRESS_SALTS_FILE', '/run/secrets/wordpress-salts'),
    true,
    512,
    JSON_THROW_ON_ERROR
);
foreach ([
    'AUTH_KEY', 'SECURE_AUTH_KEY', 'LOGGED_IN_KEY', 'NONCE_KEY',
    'AUTH_SALT', 'SECURE_AUTH_SALT', 'LOGGED_IN_SALT', 'NONCE_SALT',
] as $name) {
    if (!isset($salts[$name]) || !is_string($salts[$name]) || strlen($salts[$name]) < 32) {
        throw new RuntimeException('Authentication keys are missing or too short.');
    }
    define($name, $salts[$name]);
}

$table_prefix = getenv('WORDPRESS_TABLE_PREFIX') ?: 'wp_';
if (!preg_match('/^[A-Za-z0-9_]+$/', $table_prefix)) {
    throw new RuntimeException('Invalid WordPress table prefix.');
}

// Optional URL overrides for moving the existing database to a new endpoint.
foreach (['WP_HOME' => 'WORDPRESS_HOME', 'WP_SITEURL' => 'WORDPRESS_SITEURL'] as $constant => $variable) {
    $value = getenv($variable);
    if ($value !== false && $value !== '') {
        define($constant, $value);
    }
}

// Enable only behind a proxy configured to overwrite forwarded headers.
if (filter_var(getenv('WORDPRESS_TRUST_PROXY_HEADERS') ?: 'false', FILTER_VALIDATE_BOOLEAN)) {
    if (($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '') === 'https') {
        $_SERVER['HTTPS'] = 'on';
    }
}

define('WP_DEBUG', false);
define('DISALLOW_FILE_MODS', true);
define('WP_ENVIRONMENT_TYPE', getenv('WORDPRESS_ENVIRONMENT_TYPE') ?: 'production');

unset($readSecret, $dbHost, $dbSsl, $salts, $name, $constant, $variable, $value);

if (!defined('ABSPATH')) {
    define('ABSPATH', __DIR__ . '/');
}
require_once ABSPATH . 'wp-settings.php';
