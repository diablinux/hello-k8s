#!/bin/sh
set -e

gunicorn \
    --workers "${GUNICORN_WORKERS:-2}" \
    --bind 127.0.0.1:8000 \
    --access-logfile - \
    --error-logfile - \
    hello.hello:app &

exec nginx -g 'daemon off;'