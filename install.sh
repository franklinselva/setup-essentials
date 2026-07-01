#!/bin/bash
# One-line installer dispatcher for setup-essentials.
#
#   Interactive menu:   bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/install.sh)
#   Direct target:      bash <(curl -sSL .../install.sh) jetson-docker
#   Local:              ./install.sh jetson-ros2
#
# Runs the target script from the local checkout if present, else fetches it
# from GitHub raw. Extra args are forwarded to the target (e.g. ubuntu-ros2 jazzy).

set -euo pipefail

RAW_BASE="https://raw.githubusercontent.com/franklinselva/setup-essentials/main"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || true)"

# target key -> relative script path
declare -A TARGETS=(
  [jetson-ros2]="jetson/ros2-jazzy-install.sh"
  [jetson-realsense]="jetson/install-librealsense.sh"
  [jetson-docker]="jetson/install-docker.sh"
  [ubuntu-ros2]="ubuntu/ros2-install.sh"
  [ubuntu-ros2-uninstall]="ubuntu/ros2-uninstall.sh"
  [ubuntu-ros2-humble-src]="ubuntu/ros2-humble-source-install.sh"
  [ubuntu-depthai]="ubuntu/depthai-install.sh"
  [ubuntu-opencv]="ubuntu/opencv-install.sh"
)

# preserved menu order
ORDER=(jetson-ros2 jetson-realsense jetson-docker ubuntu-ros2 ubuntu-ros2-uninstall ubuntu-ros2-humble-src ubuntu-depthai ubuntu-opencv)

declare -A DESC=(
  [jetson-ros2]="Jetson: ROS 2 Jazzy desktop (JetPack 7.x / Ubuntu 24.04)"
  [jetson-realsense]="Jetson: Intel RealSense SDK (source, RSUSB + CUDA)"
  [jetson-docker]="Jetson: Docker Engine + NVIDIA Container Toolkit"
  [ubuntu-ros2]="Ubuntu: ROS 2 <distro> desktop-full (arg: distro, e.g. jazzy)"
  [ubuntu-ros2-uninstall]="Ubuntu: uninstall ROS 2 <distro> (arg: distro)"
  [ubuntu-ros2-humble-src]="Ubuntu: build ROS 2 Humble from source"
  [ubuntu-depthai]="Ubuntu: DepthAI / Luxonis OAK dependencies"
  [ubuntu-opencv]="Ubuntu: build OpenCV from source (+contrib; --cuda optional)"
)

run_target() {
  local key="$1"; shift
  local rel="${TARGETS[$key]:-}"
  if [ -z "$rel" ]; then
    echo "Unknown target: $key"; echo; usage; exit 1
  fi
  echo ">> $key -> $rel"
  if [ -n "$REPO_DIR" ] && [ -f "$REPO_DIR/$rel" ]; then
    bash "$REPO_DIR/$rel" "$@"
  else
    bash <(curl -sSL "$RAW_BASE/$rel") "$@"
  fi
}

usage() {
  echo "Usage: install.sh [target] [args...]"
  echo "Targets:"
  local i=1
  for k in "${ORDER[@]}"; do
    printf "  %-24s %s\n" "$k" "${DESC[$k]}"
    i=$((i + 1))
  done
}

menu() {
  echo "setup-essentials — pick a target:"
  local i=1
  for k in "${ORDER[@]}"; do
    printf "  %2d) %-24s %s\n" "$i" "$k" "${DESC[$k]}"
    i=$((i + 1))
  done
  printf "Choice [1-%d]: " "${#ORDER[@]}"
  read -r choice
  if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#ORDER[@]}" ]; then
    echo "Invalid choice."; exit 1
  fi
  run_target "${ORDER[$((choice - 1))]}"
}

if [ "$#" -eq 0 ]; then
  menu
else
  case "$1" in
    -h | --help | help) usage ;;
    *) run_target "$@" ;;
  esac
fi
