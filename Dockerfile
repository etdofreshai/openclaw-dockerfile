FROM node:22-bookworm-slim

# Small init so signals/reaping work correctly
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    tini \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Persistent install dir for OpenClaw
VOLUME ["/app", "/data"]

ENV PATH="/app/bin:${PATH}" \
    OPENCLAW_STATE_DIR="/data/.openclaw" \
    OPENCLAW_WORKSPACE_DIR="/data/workspace" \
    PORT="8080" \
    OPENCLAW_GATEWAY_PORT="18789"

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
