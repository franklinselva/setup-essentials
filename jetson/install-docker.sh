#!/bin/bash
# Install Docker Engine + NVIDIA Container Toolkit on a Jetson running
# JetPack 7.x / Ubuntu 24.04 (noble, arm64), and set the nvidia runtime as
# default so containers get GPU/CUDA access without --runtime nvidia.
#
# Docker Engine comes from Docker's official apt repo (not snap — the snap
# build breaks the NVIDIA runtime). The container toolkit comes from the
# JetPack apt repo. Docs: https://nvidia.github.io/container-wiki/toolkit/jetson.html
#
# Usage / curl one-liner:
#   bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/jetson/install-docker.sh)

set -euo pipefail

# --- Snap Docker conflicts with the NVIDIA runtime — remove it if present ---
if command -v snap >/dev/null 2>&1 && snap list docker >/dev/null 2>&1; then
  echo "Removing snap-installed Docker (incompatible with the NVIDIA runtime)."
  sudo snap remove docker
fi

# --- Docker Engine (official apt repo) ---
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- NVIDIA Container Toolkit (JetPack apt repo) ---
sudo apt install -y nvidia-container-toolkit

# --- Register the nvidia runtime with Docker and make it the default ---
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo systemctl restart docker

# --- Run Docker without sudo ---
sudo usermod -aG docker "$USER"

echo "Docker + NVIDIA Container Toolkit installed; nvidia is the default runtime."
echo "Log out and back in for docker group membership, then verify:"
echo "  docker run --rm hello-world"
