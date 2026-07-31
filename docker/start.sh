#!/bin/sh
set -e

# Default container app path, with local dev fallback when running from repo.
APP_DIR="${APP_DIR:-/service}"
if [ ! -d "$APP_DIR/hello" ]; then
    SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
    if [ -d "$SCRIPT_DIR/../hello" ]; then
        APP_DIR="$SCRIPT_DIR/.."
    fi
fi

cd "$APP_DIR"

gunicorn \
    --workers "${GUNICORN_WORKERS:-2}" \
    --bind 127.0.0.1:8000 \
    --access-logfile - \
    --error-logfile - \
    hello.hello:app &

exec nginx -g 'daemon off;'