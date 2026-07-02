#!/bin/bash
# Start the devcontainer in detached mode and exit.
# Use with: ./scripts/devcontainer-up.sh && devcontainer exec --workspace-folder . /bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IMAGE="ubuntu-setup-dev:latest"
CONTAINER="ubuntu-setup-dev"
CONFIG_FILE="$ROOT_DIR/.devcontainer/devcontainer.json"

if docker ps -q --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Container already running: $CONTAINER"
    exit 0
fi

if docker ps -aq --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Starting existing container: $CONTAINER"
    docker start "$CONTAINER" >/dev/null
    exit 0
fi

echo "Building devcontainer image..."
docker build -f .devcontainer/Dockerfile -t "$IMAGE" .devcontainer

echo "Starting devcontainer..."
docker run -d --name "$CONTAINER" \
    --label "devcontainer.local_folder=$ROOT_DIR" \
    --label "devcontainer.config_file=$CONFIG_FILE" \
    --env-file .devcontainer/.env \
    -e GIT_USER_EMAIL="${GIT_USER_EMAIL:-njmcloud@gmail.com}" \
    -e GIT_USER_NAME="${GIT_USER_NAME:-omoinjm}" \
    --privileged \
    --dns 8.8.8.8 --dns 8.8.4.4 \
    -v "$ROOT_DIR:/workspaces/ubuntu-setup" \
    -v "$HOME/.ssh:/home/vscode/.ssh:cached" \
    -v ubuntu.setup-bashhistory:/commandhistory \
    -w /workspaces/ubuntu-setup \
    "$IMAGE"

docker exec -u vscode -w /workspaces/ubuntu-setup "$CONTAINER" \
    bash .devcontainer/scripts/post-create-commands.sh

echo "Container ready: $CONTAINER"
