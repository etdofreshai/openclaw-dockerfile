FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    tini \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard

RUN cat > /usr/local/bin/run-openclaw.sh <<'EOF'
#!/usr/bin/env bash
set -u

count=0
window_start=$(date +%s)

while true; do
  now=$(date +%s)

  if [ $((now - window_start)) -ge 300 ]; then
    count=0
    window_start=$now
  fi

  count=$((count + 1))

  if [ "$count" -gt 3 ]; then
    echo "openclaw gateway exited too many times within 5 minutes; stopping container"
    exit 1
  fi

  echo "starting openclaw gateway attempt $count"
  openclaw gateway
  exit_code=$?

  echo "openclaw gateway exited with code $exit_code"
  sleep 1
done
EOF

RUN chmod +x /usr/local/bin/run-openclaw.sh

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/usr/local/bin/run-openclaw.sh"]
