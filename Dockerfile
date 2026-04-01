FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash \
  ca-certificates \
  curl \
  tini \
  lsof \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

RUN cat > /usr/local/bin/run-openclaw.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

PORT="${OPENCLAW_GATEWAY_PORT:-18789}"

# Wait for the port to become free before starting.
# This avoids racing a previous shutdown or a still-bound socket.
while lsof -iTCP:"$PORT" -sTCP:LISTEN -n -P >/dev/null 2>&1; do
  echo "port $PORT still in use; waiting..."
  sleep 1
done

echo "starting openclaw gateway"
exec openclaw gateway
EOF

RUN chmod +x /usr/local/bin/run-openclaw.sh

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/run-openclaw.sh"]
