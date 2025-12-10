#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

mkdir -p n8n_data
chmod 777 n8n_data -Rf

# if no sudo access enable rootless docker and dont run with sudo
sudo -l >/dev/null 2>&1
if [ $? -eq 0 ]; then

    echo "User has sudo privileges"
    sudo systemctl start docker
    docker_cmd="sudo docker"

else

    echo "User does NOT have sudo privileges"

start_rootless_docker() {
    local MAX_RETRIES=20
    local RETRY_INTERVAL=2
    local ATTEMPT=1

    export XDG_RUNTIME_DIR=/run/user/$(id -u)
    dockerd-rootless-setuptool.sh install

    # Run Docker rootless daemon — use screen if available, otherwise run in background
    if command -v screen >/dev/null 2>&1; then
        echo "$(date): Starting Docker rootless daemon in a screen session..."
        screen -dmS docker-rootless bash -c "PATH=/usr/bin:/sbin:/usr/sbin:\$PATH dockerd-rootless.sh --exec-opt native.cgroupdriver=cgroupfs > ~/docker-rootless.log 2>&1"
    else
        echo "$(date): 'screen' not found, starting Docker rootless daemon in background..."
        PATH=/usr/bin:/sbin:/usr/sbin:$PATH dockerd-rootless.sh --exec-opt native.cgroupdriver=cgroupfs > ~/docker-rootless.log 2>&1 &
    fi

    # Wait for Docker daemon to be ready
    until docker info > /dev/null 2>&1; do
        if [ $ATTEMPT -le $MAX_RETRIES ]; then
            echo "$(date) Attempt $ATTEMPT of $MAX_RETRIES: Waiting for Docker daemon to start..."
            sleep $RETRY_INTERVAL
            ((ATTEMPT++))
        else
            echo "$(date) ERROR: Docker daemon failed to start after $MAX_RETRIES attempts."
            return 1
        fi
    done

    echo "$(date): Docker daemon is ready!"
    return 0
}

start_rootless_docker()
docker_cmd="docker"

fi

echo "[1/3] Pulling images..."
$docker_cmd compose pull

echo "[2/3] Starting stack..."
$docker_cmd compose up -d

echo "[3/3] Status:"
$docker_cmd compose ps

echo
echo "✅ Up!"
echo "n8n       → http://localhost:8989"
