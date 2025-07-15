#!/bin/env bash
set -e

REPO_DIR="~/code/homelab"
REPO_URL="https://github.com/ItsAchance/homelab.git"
BRANCH="main"
LOG_FILE="~/code/homelab/gitops.log"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

cd "$REPO_DIR" || git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR" && cd "$REPO_DIR"

git fetch origin "$BRANCH"
LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/"$BRANCH")

if [ "$LOCAL_HASH" != "$REMOTE_HASH" ]; then
  echo "[INFO] New commit found, pulling changes..." > ${LOG_FILE}
  git pull origin "$BRANCH"

  echo "[INFO] Validating ${DOCKER_COMPOSE_FILE}..." > ${LOG_FILE}
  if docker-compose -f ${DOCKER_COMPOSE_FILE} config >/dev/null 2>&1; then
    echo "[INFO] Compose file is valid. Redeploying..." > ${LOG_FILE}
    docker-compose -f ${DOCKER_COMPOSE_FILE} pull
    docker-compose -f ${DOCKER_COMPOSE_FILE} up -d
  else
    echo "[ERROR] Invalid docker-compose.yml. Skipping deploy." > ${LOG_FILE}
  fi
else
  echo "[INFO] No changes detected. Skipping." > ${LOG_FILE}
fi

