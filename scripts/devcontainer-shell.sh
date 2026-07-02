#!/bin/bash
# Start or attach to the devcontainer shell (reliable alternative when devcontainer up hangs).
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

IMAGE="ubuntu-setup-dev:latest"
CONTAINER="ubuntu-setup-dev"
LABEL="devcontainer.local_folder=$ROOT_DIR"

if docker ps -q --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Using running container: $CONTAINER"
elif docker ps -aq --filter "name=^${CONTAINER}$" | grep -q .; then
    echo "Starting existing container: $CONTAINER"
    docker start "$CONTAINER" >/dev/null
else
    echo "Building devcontainer image..."
    docker build -f .devcontainer/Dockerfile -t "$IMAGE" .devcontainer

    echo "Starting devcontainer..."
    docker run -d --name "$CONTAINER" \
        --label "devcontainer.local_folder=$ROOT_DIR" \
        --label "devcontainer.config_file=$ROOT_DIR/.devcontainer/devcontainer.json" \
        --label "$LABEL" \
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
fi

echo "Attaching to $CONTAINER..."
exec docker exec -it -u vscode -w /workspaces/ubuntu-setup "$CONTAINER" /bin/bash
