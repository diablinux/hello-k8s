#!/bin/sh
set -eu

NAMESPACE="${NAMESPACE:-default}"
SERVICE_NAME="${SERVICE_NAME:-hello-k8s}"
REQUESTS="${REQUESTS:-10}"
TMP_POD="${TMP_POD:-hello-k8s-smoke}"

echo "Testing service ${SERVICE_NAME} in namespace ${NAMESPACE}"
echo "Running ${REQUESTS} requests from a temporary curl pod to sample both replicas."

kubectl -n "$NAMESPACE" run "$TMP_POD" \
    --image=curlimages/curl:8.7.1 \
    --restart=Never \
    --env=NAMESPACE="$NAMESPACE" \
    --env=SERVICE_NAME="$SERVICE_NAME" \
    --env=REQUESTS="$REQUESTS" \
    --rm -i --quiet \
    --command -- sh -eu <<'EOF'
service_url="http://${SERVICE_NAME}.${NAMESPACE}.svc.cluster.local"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

unique_hosts=""

i=1
while [ "$i" -le "$REQUESTS" ]; do
    headers_file="$tmp_dir/headers-$i.txt"
    body_file="$tmp_dir/body-$i.txt"

    curl -sS -D "$headers_file" -o "$body_file" "$service_url/health"

    proxy_header="$(grep -i '^X-Proxy:' "$headers_file" | awk '{print $2}' | tr -d '\r')"
    app_header="$(grep -i '^X-App:' "$headers_file" | awk '{print $2}' | tr -d '\r')"

    if [ "$proxy_header" != nginx ]; then
        echo "Request $i failed: expected X-Proxy: nginx, got ${proxy_header:-missing}"
        exit 1
    fi

    if [ "$app_header" != flask ]; then
        echo "Request $i failed: expected X-App: flask, got ${app_header:-missing}"
        exit 1
    fi

    if ! grep -q '^OK!$' "$body_file"; then
        echo "Request $i failed: unexpected /health body"
        cat "$body_file"
        exit 1
    fi

    body_json="$(curl -sS "$service_url/")"
    hostname="$(printf '%s' "$body_json" | sed -n 's/.*"hostname":[[:space:]]*"\([^"]*\)".*/\1/p')"

    if [ -n "$hostname" ]; then
        case " $unique_hosts " in
            *" $hostname "*) ;;
            *) unique_hosts="$unique_hosts $hostname" ;;
        esac
    fi

    printf 'Request %s: X-Proxy=%s X-App=%s Host=%s\n' "$i" "$proxy_header" "$app_header" "${hostname:-unknown}"
    i=$((i + 1))
done

set -- $unique_hosts
echo "Unique pod hostnames seen: $#"
printf '%s\n' $unique_hosts

if [ "$#" -lt 1 ]; then
    echo "Warning: did not capture a hostname from the app response."
fi

if [ "$#" -lt 2 ]; then
    echo "Note: only one pod hostname was observed in this sample. With two replicas, rerun the script or increase REQUESTS to sample load balancing more thoroughly."
fi
EOF