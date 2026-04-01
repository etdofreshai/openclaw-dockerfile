FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    tini \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["bash", "-lc", "\
count=0; \
window_start=$(date +%s); \
while true; do \
  now=$(date +%s); \
  if [ $((now - window_start)) -ge 300 ]; then \
    count=0; \
    window_start=$now; \
  fi; \
  count=$((count + 1)); \
  if [ \"$count\" -gt 3 ]; then \
    echo 'openclaw exited too many times within 5 minutes; stopping container'; \
    exit 1; \
  fi; \
  echo \"starting openclaw attempt $count\"; \
  curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard; \
  echo 'openclaw exited'; \
  sleep 1; \
done"]
