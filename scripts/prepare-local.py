#!/usr/bin/env python3
"""Prepare ignored, local-only secrets and a digest-pinned MySQL image input."""

import json
import os
from pathlib import Path
import re
import secrets


def write_secret_once(path, value):
    if path.exists():
        if not path.is_file() or path.stat().st_size == 0:
            raise SystemExit(f"Invalid existing secret file: {path}")
        # The parent directory is private to the host user. File readability
        # permits the container's non-root UID to read the read-only bind mount.
        path.chmod(0o644)
        return
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o644)
    with os.fdopen(descriptor, "w", encoding="utf-8") as target:
        os.fchmod(target.fileno(), 0o644)
        target.write(value)


def main():
    image = Path("docker/mysql-image.txt").read_text().strip()
    if not re.fullmatch(r"\S+@sha256:[0-9a-f]{64}", image):
        raise SystemExit("docker/mysql-image.txt must contain a pinned image digest.")

    local = Path(".local")
    local.mkdir(mode=0o700, exist_ok=True)
    local.chmod(0o700)
    directory = local / "secrets"
    directory.mkdir(mode=0o700, exist_ok=True)
    directory.chmod(0o700)

    write_secret_once(directory / "mysql-root-password", secrets.token_urlsafe(32))
    write_secret_once(directory / "wordpress-db-password", secrets.token_urlsafe(32))
    names = (
        "AUTH_KEY", "SECURE_AUTH_KEY", "LOGGED_IN_KEY", "NONCE_KEY",
        "AUTH_SALT", "SECURE_AUTH_SALT", "LOGGED_IN_SALT", "NONCE_SALT",
    )
    write_secret_once(
        directory / "wordpress-salts",
        json.dumps({name: secrets.token_hex(64) for name in names}),
    )

    environment = Path(".env")
    lines = environment.read_text().splitlines() if environment.exists() else []
    lines = [line for line in lines if not line.startswith("MYSQL_IMAGE=")]
    lines.append(f"MYSQL_IMAGE={image}")
    environment.write_text("\n".join(lines) + "\n")
    environment.chmod(0o600)

    print("Local secret files are ready; existing values were preserved.")
    print("Pinned MySQL image configured in .env. No secret values were printed.")


if __name__ == "__main__":
    main()
