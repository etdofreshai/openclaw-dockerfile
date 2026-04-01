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
export PATH="${APP_DIR}/bin:${PATH}"

OPENCLAW_BIN="${APP_DIR}/bin/openclaw"

install_openclaw() {
  echo "[openclaw] Installing OpenClaw into ${APP_DIR}..."
  npm install --prefix "${APP_DIR}" "openclaw@${OPENCLAW_VERSION}"
}

update_openclaw() {
  echo "[openclaw] Updating OpenClaw in ${APP_DIR} to ${OPENCLAW_VERSION}..."
  npm install --prefix "${APP_DIR}" "openclaw@${OPENCLAW_VERSION}"
}

if [[ ! -x "${OPENCLAW_BIN}" ]]; then
  install_openclaw
elif [[ "${AUTO_UPDATE}" == "true" ]]; then
  update_openclaw
fi

echo "[openclaw] Using binary: ${OPENCLAW_BIN}"
"${OPENCLAW_BIN}" --version || true

# If the user passes a custom command, run that instead.
if [[ "$#" -gt 0 ]]; then
  exec "$@"
fi

# Default: start gateway
exec "${OPENCLAW_BIN}" gateway
