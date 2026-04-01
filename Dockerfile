FROM node:22-bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    curl \
    tini \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["sleep", "infinity"]
