#!/bin/bash
# Install ROS 2 Jazzy Jalisco (desktop) on a Jetson running JetPack 7.x / Ubuntu 24.04 (noble, arm64).
# Follows the official ROS 2 Jazzy Debian-package procedure:
# https://docs.ros.org/en/jazzy/Installation/Ubuntu-Install-Debs.html
#
# Usage (curl one-liner):
#   bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/ros/ros2-jazzy-jetson-install.sh)

set -euo pipefail

# --- Preflight: Jazzy requires Ubuntu 24.04 (noble). JetPack 7.x ships noble arm64. ---
source /etc/os-release
if [ "${VERSION_CODENAME:-}" != "noble" ]; then
  echo "Error: ROS 2 Jazzy requires Ubuntu 24.04 (noble). Detected: ${VERSION_CODENAME:-unknown}."
  echo "On a Jetson this means JetPack 7.x. Aborting."
  exit 1
fi

# --- Set locale (UTF-8) ---
sudo apt update && sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# --- Enable the Universe repository ---
sudo apt install -y software-properties-common
sudo add-apt-repository -y universe

# --- Add the ROS 2 apt source (auto-updating repo config via ros2-apt-source .deb) ---
sudo apt update && sudo apt install -y curl
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb \
  "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo "$VERSION_CODENAME")_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# --- Install ROS 2 Jazzy desktop + development tools ---
sudo apt update
sudo apt upgrade -y
sudo apt install -y ros-jazzy-desktop
sudo apt install -y ros-dev-tools

# --- Environment ---
if ! grep -qF "source /opt/ros/jazzy/setup.bash" "$HOME/.bashrc"; then
  echo "source /opt/ros/jazzy/setup.bash" >> "$HOME/.bashrc"
fi

echo "ROS 2 Jazzy desktop installed. Open a new shell or run: source /opt/ros/jazzy/setup.bash"
