#!/bin/sh
set -eu

SERVICE_URL="${SERVICE_URL:-http://IP_ADDRESS}"
REQUESTS="${REQUESTS:-10}"
CONNECT_TIMEOUT_SECONDS="${CONNECT_TIMEOUT_SECONDS:-2}"
MAX_TIME_SECONDS="${MAX_TIME_SECONDS:-10}"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

unique_hosts=""

echo "Testing ${SERVICE_URL}"
echo "Running ${REQUESTS} requests to sample both replicas if they are active."

i=1
while [ "$i" -le "$REQUESTS" ]; do
    headers_file="$tmp_dir/headers-$i.txt"
    body_file="$tmp_dir/body-$i.txt"

    curl -sS \
        --connect-timeout "$CONNECT_TIMEOUT_SECONDS" \
        --max-time "$MAX_TIME_SECONDS" \
        -D "$headers_file" \
        -o "$body_file" \
        "$SERVICE_URL/health"

    proxy_header="$(grep -i '^X-Proxy:' "$headers_file" | awk '{print $2}' | tr -d '\r')"
    app_header="$(grep -i '^X-App:' "$headers_file" | awk '{print $2}' | tr -d '\r')"
    status_line="$(head -n 1 "$headers_file")"

    if [ "$proxy_header" != "nginx" ]; then
        echo "Request $i failed: expected X-Proxy: nginx, got ${proxy_header:-missing}"
        exit 1
    fi

    if [ "$app_header" != "flask" ]; then
        echo "Request $i failed: expected X-App: flask, got ${app_header:-missing}"
        exit 1
    fi

    if ! grep -q '^OK!$' "$body_file"; then
        echo "Request $i failed: unexpected /health body"
        cat "$body_file"
        exit 1
    fi

    body_json="$(curl -sS \
        --connect-timeout "$CONNECT_TIMEOUT_SECONDS" \
        --max-time "$MAX_TIME_SECONDS" \
        "$SERVICE_URL/")"
    hostname="$(printf '%s' "$body_json" | sed -n 's/.*"hostname":[[:space:]]*"\([^"]*\)".*/\1/p')"

    if [ -n "$hostname" ]; then
        case " $unique_hosts " in
            *" $hostname "*) ;;
            *) unique_hosts="$unique_hosts $hostname" ;;
        esac
    fi

    printf '%s\n' "$status_line"
    printf '  X-Proxy=%s X-App=%s Host=%s\n' "$proxy_header" "$app_header" "${hostname:-unknown}"

    i=$((i + 1))
done

set -- $unique_hosts
echo "Unique pod hostnames seen: $#"
printf '%s\n' "$unique_hosts"

if [ "$#" -lt 1 ]; then
    echo "Warning: did not capture a hostname from the app response."
fi

if [ "$#" -lt 2 ]; then
    echo "Note: only one pod hostname was observed in this sample. With two replicas, rerun the script or increase REQUESTS to sample load balancing more thoroughly."
fi