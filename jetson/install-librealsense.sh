#!/bin/bash
# Build and install librealsense (Intel RealSense SDK 2.0) on a Jetson running
# JetPack 7.x / Ubuntu 24.04 (noble, arm64).
#
# Uses the RSUSB (libuvc) backend so no kernel patching / DKMS is required — the
# L4T kernel is not a mainline Ubuntu kernel, so the apt/dkms path does not work
# on Jetson. Builds with CUDA by default. Source: realsenseai/librealsense.
#   Docs: https://dev.realsenseai.com/installation/nvidia-jetson-installation/
#
# Usage:
#   ./install-librealsense-jetson.sh [-n|--no_cuda] [-v|--version <tag>] [-j|--jobs <n>]
# Curl one-liner:
#   bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/jetson/install-librealsense.sh)

set -euo pipefail

REPO_URL="https://github.com/realsenseai/librealsense.git"
SRC_DIR="${HOME}/librealsense"
USE_CUDA=true
VERSION=""
NUM_PROCS=""

usage() {
  echo "Usage: $0 [-n|--no_cuda] [-v|--version <tag>] [-j|--jobs <n>] [-h|--help]"
  echo "  -n | --no_cuda   Build without CUDA (default: with CUDA)"
  echo "  -v | --version   librealsense tag to build (default: latest release)"
  echo "  -j | --jobs      Parallel build jobs (default: nproc-1 if >4GB RAM, else 1)"
  exit 2
}

PARSED=$(getopt -a -n "$0" -o nv:j:h --longoptions no_cuda,version:,jobs:,help -- "$@") || usage
eval set -- "$PARSED"
while :; do
  case "$1" in
    -n | --no_cuda) USE_CUDA=false; shift ;;
    -v | --version) VERSION="$2"; shift 2 ;;
    -j | --jobs)    NUM_PROCS="$2"; shift 2 ;;
    -h | --help)    usage ;;
    --) shift; break ;;
    *) usage ;;
  esac
done

# --- Preflight: arm64 + (optionally) CUDA ---
if [ "$(dpkg --print-architecture)" != "arm64" ]; then
  echo "Warning: expected arm64 (Jetson). Detected: $(dpkg --print-architecture)."
fi
if [ "$USE_CUDA" = true ] && [ ! -x /usr/local/cuda/bin/nvcc ]; then
  echo "nvcc not found — installing CUDA toolkit from the JetPack apt repo."
  sudo apt update
  # Pick the newest cuda-toolkit-<major>-<minor> available (JetPack 7.x ships CUDA 13.x);
  # avoids pinning a minor that drifts across point releases.
  CUDA_PKG=$(apt-cache pkgnames cuda-toolkit-1 | sort -V | tail -1)
  sudo apt install -y "${CUDA_PKG:-cuda-toolkit}"
  if [ ! -x /usr/local/cuda/bin/nvcc ]; then
    echo "Error: CUDA toolkit install did not provide /usr/local/cuda/bin/nvcc."
    echo "Install JetPack CUDA (e.g. 'sudo apt install nvidia-jetpack') or rerun with --no_cuda."
    exit 1
  fi
fi

# --- Dependencies (no qtcreator; libudev-dev required for RSUSB backend) ---
sudo apt update
sudo apt install -y \
  git cmake build-essential pkg-config \
  libssl-dev libusb-1.0-0-dev libudev-dev \
  v4l-utils libv4l-dev \
  libgtk-3-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev \
  python3 python3-dev python3-pip

# --- Fetch source ---
if [ ! -d "$SRC_DIR" ]; then
  git clone "$REPO_URL" "$SRC_DIR"
fi
cd "$SRC_DIR"
git fetch --tags
if [ -z "$VERSION" ]; then
  VERSION=$(curl -s https://api.github.com/repos/realsenseai/librealsense/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
fi
echo "Building librealsense $VERSION (CUDA: $USE_CUDA)"
git checkout "$VERSION"

# --- udev rules: user-space USB access for the camera ---
./scripts/setup_udev_rules.sh
sudo udevadm control --reload-rules
sudo udevadm trigger
sudo usermod -aG plugdev "$USER"

# --- Build (RSUSB backend, no kernel patch) ---
mkdir -p build && cd build
if [ "$USE_CUDA" = true ]; then
  export CUDACXX=/usr/local/cuda/bin/nvcc
  export PATH="${PATH}:/usr/local/cuda/bin"
  export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:-}:/usr/local/cuda/lib64"
fi
cmake ../ \
  -DFORCE_RSUSB_BACKEND=ON \
  -DBUILD_WITH_CUDA="$USE_CUDA" \
  -DBUILD_EXAMPLES=ON \
  -DBUILD_PYTHON_BINDINGS=ON \
  -DCMAKE_BUILD_TYPE=Release

# --- Job count: mem-aware default ---
if [ -z "$NUM_PROCS" ]; then
  TOTAL_MEMORY=$(free | awk '/Mem:/ { print $2 }')
  if [ "$TOTAL_MEMORY" -gt 4051048 ]; then
    NUM_PROCS=$(($(nproc) - 1))
  else
    NUM_PROCS=1
  fi
fi

make -j"$NUM_PROCS"
sudo make install

# --- Python wrapper path ---
PYLINE='export PYTHONPATH=$PYTHONPATH:/usr/local/lib'
if ! grep -Fxq "$PYLINE" "$HOME/.bashrc"; then
  echo "$PYLINE" >> "$HOME/.bashrc"
fi

echo "librealsense $VERSION installed to /usr/local (lib, include, bin)."
echo "Run 'realsense-viewer' to verify. Reconnect the camera so udev rules apply."
echo "Log out and back in for plugdev group membership to take effect."
