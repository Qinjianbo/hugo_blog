#!/usr/bin/env bash
set -euo pipefail

# Deploy Hugo site to remote server via rsync.
# Usage: chmod +x deploy.sh && ./deploy.sh
# Required env vars:
#   REMOTE_USER
#   REMOTE_HOST
#   REMOTE_PATH
# Optional env vars:
#   SSH_PORT  (default: 22)
#   BUILD_DIR (default: public)
#   DRY_RUN   (set to 1 for rsync --dry-run)

required_env_vars=(REMOTE_USER REMOTE_HOST REMOTE_PATH)
missing_env_vars=()

for env_var in "${required_env_vars[@]}"; do
  if [[ -z "${!env_var:-}" ]]; then
    missing_env_vars+=("${env_var}")
  fi
done

if (( ${#missing_env_vars[@]} > 0 )); then
  echo "Missing required environment variables: ${missing_env_vars[*]}" >&2
  echo "Please set them before running deploy.sh." >&2
  echo "Example:" >&2
  echo "  export REMOTE_USER='your-user'" >&2
  echo "  export REMOTE_HOST='your-server-host'" >&2
  echo "  export REMOTE_PATH='/path/to/deploy-dir'" >&2
  exit 1
fi

REMOTE_USER=${REMOTE_USER}
REMOTE_HOST=${REMOTE_HOST}
REMOTE_PATH=${REMOTE_PATH}
SSH_PORT=${SSH_PORT:-22}
BUILD_DIR=${BUILD_DIR:-public}

echo "==> Building site with drafts (hugo -D)..."
hugo -D --cleanDestinationDir -d "${BUILD_DIR}"

echo "==> Syncing to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
RSYNC_FLAGS=(-avz --delete --exclude '.DS_Store' --exclude 'Thumbs.db')
[[ "${DRY_RUN:-0}" == "1" ]] && RSYNC_FLAGS+=(--dry-run) && echo "DRY RUN enabled"

rsync "${RSYNC_FLAGS[@]}" \
  -e "ssh -p ${SSH_PORT}" \
  "${BUILD_DIR}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo "✅ Deploy finished."
