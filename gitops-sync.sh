#!/usr/bin/env bash
set -e

REPO_DIR="/Users/achance/code/homelab"
REPO_URL="https://github.com/ItsAchance/homelab.git"
BRANCH="main"
LOG_FILE="${REPO_DIR}/gitops.log"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

cd "$REPO_DIR" || git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR" && cd "$REPO_DIR"

git fetch origin "$BRANCH"
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/"$BRANCH")

if [ ! -f ${LOG_FILE} ]; then
    echo "$(date)[INFO] ${LOG_FILE} not present, creating it..." >> ${LOG_FILE}
    touch ${LOG_FILE}
fi

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
    echo "$(date)[INFO] New commit found, pulling changes..." >> ${LOG_FILE}
  git pull origin "$BRANCH"

  echo "[INFO] Validating ${DOCKER_COMPOSE_FILE}..." >> ${LOG_FILE}
  if docker-compose -f ${DOCKER_COMPOSE_FILE} config >/dev/null 2>&1; then
      echo "$(date)[INFO] Compose file is valid. Redeploying..." >> ${LOG_FILE}
    docker-compose -f ${DOCKER_COMPOSE_FILE} pull
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
  else
      echo "$(date)[ERROR] Invalid docker-compose.yml. Skipping deploy." >> ${LOG_FILE}
  fi
else
    echo "$(date)[INFO] No changes detected. Skipping." >> ${LOG_FILE}
fi

