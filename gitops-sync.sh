#!/usr/bin/env bash

# This is a bash script that mimics some of FluxCD's behavior.
# It uses a GitHub repo as the source of truth and will discard any locally
# commited changes to keep in sync with the remote repo. This runs as a systemd
# unit on the target machine.

REPO_DIR="/opt/homelab"
REPO_URL="https://github.com/ItsAchance/homelab.git"
BRANCH="main"
LOG_FILE="${REPO_DIR}/gitops.log"
DOCKER_COMPOSE_FILE="docker-compose.yaml"

cd ${REPO_DIR}
git fetch origin "${BRANCH}"

LOCAL_HASH=$(git rev-parse HEAD)
REMOTE_HASH=$(git rev-parse origin/"${BRANCH}")

if [ ! -f ${LOG_FILE} ]; then
    echo "[INFO] $(date) ${LOG_FILE} not present, creating it..." >> ${LOG_FILE}
    touch ${LOG_FILE}
fi

if [ "${LOCAL_HASH}" != "${REMOTE_HASH}" ]; then
    echo "[INFO] $(date) New commit found, pulling changes..." >> ${LOG_FILE}
    git fetch origin "${BRANCH}"
    git reset --hard origin/"${BRANCH}"
    git pull origin "${BRANCH}"

    echo "[INFO] $(date) Validating ${DOCKER_COMPOSE_FILE}..." >> ${LOG_FILE}
    if docker compose -f ${DOCKER_COMPOSE_FILE} config >/dev/null 2>&1; then
        echo "[INFO] $(date) Compose file is valid. Redeploying..." >> ${LOG_FILE}
        docker compose -f ${DOCKER_COMPOSE_FILE} pull
        docker compose -f ${DOCKER_COMPOSE_FILE} up -d --remove-orphans
        echo "[INFO] $(date) Deploy successful." >> ${LOG_FILE}
    else
        echo "[ERROR] $(date) Invalid compose file. Skipping deploy." >> ${LOG_FILE}
    fi

else
    echo "[INFO] $(date) No changes detected. Skipping." >> ${LOG_FILE}
fi
