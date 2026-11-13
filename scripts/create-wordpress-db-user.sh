#!/bin/sh
set -eu

python3 - "$@" <<'PY'
import json
import re
import subprocess
import sys
import tempfile
import urllib.error
import urllib.request

def main():
    vault, host = sys.argv[1:3]
    opener = urllib.request.build_opener(
        urllib.request.ProxyHandler({})
    )

    def get_json(url, headers):
        request = urllib.request.Request(url, headers=headers)
        with opener.open(request, timeout=30) as response:
            return json.load(response)

    token = get_json(
        "http://169.254.169.254/metadata/identity/oauth2/token"
        "?api-version=2018-02-01"
        "&resource=https%3A%2F%2Fvault.azure.net",
        {"Metadata": "true"},
    )["access_token"]

    def get_secret(name):
        return get_json(
            f"https://{vault}.vault.azure.net/secrets/{name}"
            "?api-version=7.4",
            {"Authorization": f"Bearer {token}"},
        )["value"]

    admin_password = get_secret("mysql-admin-password")
    app_password = get_secret("wordpress-db-password")

    def run_mysql(username, password, sql, database=None):
        escaped = (
            password.replace("\\", "\\\\")
            .replace('"', '\\"')
            .replace("\n", "\\n")
            .replace("\r", "\\r")
        )

        # Temporary file is owner-only and removed on exit.
        with tempfile.NamedTemporaryFile(
            mode="w", dir="/run", prefix="wp-db-"
        ) as config:
            config.write(
                f'[client]\nuser={username}\npassword="{escaped}"\n'
            )
            config.flush()

            command = [
                "mysql",
                f"--defaults-file={config.name}",
                "--protocol=TCP",
                f"--host={host}",
                "--connect-timeout=10",
                "--ssl-mode=VERIFY_IDENTITY",
                "--ssl-ca=/etc/ssl/certs/ca-certificates.crt",
                "--batch",
            ]
            if database:
                command.append(f"--database={database}")

            result = subprocess.run(
                command,
                input=sql,
                text=True,
                capture_output=True,
                timeout=60,
            )

        if result.returncode:
            code = re.search(r"ERROR \d+", result.stderr)
            label = code.group() if code else "client failure"
            raise RuntimeError(f"MySQL operation failed: {label}")

        return result.stdout

    # Escape the SQL string for the explicitly selected session mode.
    password_sql = (
        app_password.replace("\\", "\\\\")
        .replace("'", "''")
        .replace("\n", "\\n")
        .replace("\r", "\\r")
    )

    run_mysql(
        "wpadmin",
        admin_password,
        f"""
        SET SESSION sql_mode='STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';
        CREATE USER IF NOT EXISTS 'wpapp'@'%'
          IDENTIFIED BY '{password_sql}' REQUIRE SSL;
        ALTER USER 'wpapp'@'%'
          IDENTIFIED BY '{password_sql}' REQUIRE SSL;
        GRANT ALL PRIVILEGES ON `wordpress`.* TO 'wpapp'@'%';
        """,
    )

    print(run_mysql(
        "wpapp",
        app_password,
        "SELECT CURRENT_USER(), DATABASE(); "
        "SHOW GRANTS FOR CURRENT_USER();",
        database="wordpress",
    ))
    print("WORDPRESS-database-user-check-passed")

try:
    main()
except urllib.error.HTTPError as error:
    print(f"Azure credential request failed: HTTP {error.code}",
          file=sys.stderr)
    sys.exit(1)
except RuntimeError as error:
    print(str(error), file=sys.stderr)
    sys.exit(1)
except Exception as error:
    print(f"Setup failed: {type(error).__name__}; "
          "credential details withheld.", file=sys.stderr)
    sys.exit(1)
PY
