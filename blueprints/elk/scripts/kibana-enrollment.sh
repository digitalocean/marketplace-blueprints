#!/usr/bin/env bash
# Fetches KIBANA_ENROLLMENT_TOKEN from Elasticsearch, runs kibana-setup on Kibana, then falls back to
# password auth if enrollment fails (common when Elasticsearch was reconfigured for HTTP / custom security).
set -euo pipefail

ES_IP="${1:?Elasticsearch IPv4 required}"
KB_IP="${2:?Kibana IPv4 required}"

# Optional: set by Terraform local-exec environment for fallback (same value as elasticsearch user_data).
KIBANA_FALLBACK_PASSWORD="${KIBANA_FALLBACK_PASSWORD:-}"
PW_B64_LOCAL="$(printf '%s' "$KIBANA_FALLBACK_PASSWORD" | base64 | tr -d '\n')"

SSH_OPTS=(
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o ConnectTimeout=15
)

fetch_token() {
  ssh "${SSH_OPTS[@]}" "root@${ES_IP}" \
    'set -a; source /root/.digitalocean_passwords 2>/dev/null; printf %s "$KIBANA_ENROLLMENT_TOKEN"'
}

TOKEN=""
for i in $(seq 1 90); do
  TOKEN="$(fetch_token || true)"
  if [[ -n "$TOKEN" ]]; then
    break
  fi
  echo "Waiting for KIBANA_ENROLLMENT_TOKEN on Elasticsearch (${i}/90)..."
  sleep 10
done

if [[ -z "$TOKEN" ]]; then
  echo "Failed to read KIBANA_ENROLLMENT_TOKEN from root@${ES_IP}:/root/.digitalocean_passwords" >&2
  exit 1
fi

B64="$(printf '%s' "$TOKEN" | base64 | tr -d '\n')"

ssh "${SSH_OPTS[@]}" "root@${KB_IP}" bash -s -- "$B64" "$ES_IP" "$PW_B64_LOCAL" <<'REMOTE'
set -euo pipefail
B64="$1"
ES_IP="$2"
PW_B64="$3"

if ! echo "$B64" | base64 -d > /tmp/.kibana_enrollment_token 2>/dev/null; then
  echo "$B64" | base64 --decode > /tmp/.kibana_enrollment_token
fi
if [[ ! -s /tmp/.kibana_enrollment_token ]]; then
  echo "base64 decode failed (enrollment token) on Kibana host" >&2
  exit 1
fi
chmod 600 /tmp/.kibana_enrollment_token

KIBANA_SETUP=""
for p in /usr/share/kibana/bin/kibana-setup /usr/share/kibana/node/bin/kibana-setup; do
  if [[ -x "$p" ]]; then
    KIBANA_SETUP="$p"
    break
  fi
done
if [[ -z "$KIBANA_SETUP" ]]; then
  echo "kibana-setup not found under /usr/share/kibana" >&2
  rm -f /tmp/.kibana_enrollment_token
  exit 1
fi

systemctl stop kibana 2>/dev/null || true

set +e
KIBANA_SETUP_OUT=$("$KIBANA_SETUP" --enrollment-token "$(cat /tmp/.kibana_enrollment_token)" 2>&1)
KIBANA_SETUP_RC=$?
set -e

echo "$KIBANA_SETUP_OUT"

rm -f /tmp/.kibana_enrollment_token

if [[ $KIBANA_SETUP_RC -eq 0 ]]; then
  systemctl enable kibana
  systemctl start kibana
  exit 0
fi

echo "kibana-setup failed with exit code $KIBANA_SETUP_RC" >&2

if [[ -z "$PW_B64" ]]; then
  journalctl -u kibana -n 40 --no-pager 2>/dev/null || true
  exit "$KIBANA_SETUP_RC"
fi

PW="$(echo "$PW_B64" | base64 -d 2>/dev/null || true)"
if [[ -z "$PW" ]]; then
  echo "Fallback: could not decode KIBANA_FALLBACK_PASSWORD" >&2
  exit 1
fi

echo "Using password-based Elasticsearch connection (enrollment is not compatible with this cluster configuration)." >&2

cat > /etc/kibana/kibana.yml <<YAML
server.host: "0.0.0.0"

elasticsearch.hosts: ["http://${ES_IP}:9200"]

elasticsearch.username: "kibana"
elasticsearch.password: "${PW}"

logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file

pid.file: /run/kibana/kibana.pid
YAML

systemctl enable kibana
systemctl start kibana
REMOTE

echo "Kibana enrollment (or password fallback) completed."
