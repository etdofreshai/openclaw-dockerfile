#!/usr/bin/env bash
set -Eeuo pipefail

APP_DIR="${APP_DIR:-/app}"
DATA_DIR="${DATA_DIR:-/data}"
OPENCLAW_VERSION="${OPENCLAW_VERSION:-latest}"
AUTO_UPDATE="${AUTO_UPDATE:-false}"

mkdir -p "${APP_DIR}" \
         "${DATA_DIR}/.openclaw" \
         "${DATA_DIR}/workspace"

export OPENCLAW_STATE_DIR="${OPENCLAW_STATE_DIR:-${DATA_DIR}/.openclaw}"
export OPENCLAW_WORKSPACE_DIR="${OPENCLAW_WORKSPACE_DIR:-${DATA_DIR}/workspace}"
export PATH="${APP_DIR}/node_modules/.bin:${PATH}"

install_openclaw() {
  echo "[openclaw] Installing OpenClaw into ${APP_DIR}..."
  npm install --prefix "${APP_DIR}" "openclaw@${OPENCLAW_VERSION}"
}

update_openclaw() {
  echo "[openclaw] Updating OpenClaw in ${APP_DIR} to ${OPENCLAW_VERSION}..."
  npm install --prefix "${APP_DIR}" "openclaw@${OPENCLAW_VERSION}"
}

if [[ ! -f "${APP_DIR}/package.json" ]]; then
  echo '{}' > "${APP_DIR}/package.json"
fi

if [[ ! -e "${APP_DIR}/node_modules/openclaw/openclaw.mjs" ]]; then
  install_openclaw
elif [[ "${AUTO_UPDATE}" == "true" ]]; then
  update_openclaw
fi

OPENCLAW_BIN="${APP_DIR}/node_modules/.bin/openclaw"
if [[ ! -x "${OPENCLAW_BIN}" ]]; then
  OPENCLAW_BIN="${APP_DIR}/node_modules/openclaw/openclaw.mjs"
fi

echo "[openclaw] Using binary: ${OPENCLAW_BIN}"
node "${APP_DIR}/node_modules/openclaw/openclaw.mjs" --version || true

if [[ "$#" -gt 0 ]]; then
  exec "$@"
fi

exec node "${APP_DIR}/node_modules/openclaw/openclaw.mjs" gateway
