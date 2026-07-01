#!/bin/bash
# Build and install OpenCV (+ opencv_contrib) from source on Ubuntu.
# Defaults to the latest upstream release; pin an OpenCV-4 tag with --version
# (e.g. --version 4.11.0) if your stack is not OpenCV-5 ready. CUDA is off by
# default; enable with --cuda (needs a CUDA toolkit / nvcc, e.g. on a Jetson).
#
# Usage:
#   ./opencv-install.sh [-v|--version <tag>] [--no-contrib] [--cuda] [-j|--jobs <n>]
# Curl one-liner:
#   bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/ubuntu/opencv-install.sh)

set -euo pipefail

VERSION=""
WITH_CONTRIB=true
WITH_CUDA=false
NUM_PROCS=""
SRC_DIR="${HOME}/opencv_build"

usage() {
  echo "Usage: $0 [-v|--version <tag>] [--no-contrib] [--cuda] [-j|--jobs <n>] [-h|--help]"
  echo "  -v | --version    OpenCV tag to build (default: latest release)"
  echo "       --no-contrib  Skip opencv_contrib modules (default: include)"
  echo "       --cuda        Build with CUDA (default: off; requires nvcc)"
  echo "  -j | --jobs        Parallel build jobs (default: nproc-1 if >4GB RAM, else 1)"
  exit 2
}

PARSED=$(getopt -a -n "$0" -o v:j:h --longoptions version:,no-contrib,cuda,jobs:,help -- "$@") || usage
eval set -- "$PARSED"
while :; do
  case "$1" in
    -v | --version) VERSION="$2"; shift 2 ;;
    --no-contrib)   WITH_CONTRIB=false; shift ;;
    --cuda)         WITH_CUDA=true; shift ;;
    -j | --jobs)    NUM_PROCS="$2"; shift 2 ;;
    -h | --help)    usage ;;
    --) shift; break ;;
    *) usage ;;
  esac
done

# --- Dependencies ---
sudo apt update
sudo apt install -y \
  build-essential cmake git pkg-config \
  libgtk-3-dev libavcodec-dev libavformat-dev libswscale-dev libv4l-dev \
  libxvidcore-dev libx264-dev libjpeg-dev libpng-dev libtiff-dev \
  libtbb-dev libatlas-base-dev gfortran \
  python3-dev python3-numpy

# --- Resolve version (matched core + contrib tag) ---
if [ -z "$VERSION" ]; then
  VERSION=$(curl -s https://api.github.com/repos/opencv/opencv/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
fi
echo "Building OpenCV $VERSION (contrib: $WITH_CONTRIB, CUDA: $WITH_CUDA)"

if [ "$WITH_CUDA" = true ] && [ ! -x /usr/local/cuda/bin/nvcc ]; then
  echo "Warning: --cuda set but /usr/local/cuda/bin/nvcc not found; build may fail."
fi

# --- Fetch sources at matching tags ---
mkdir -p "$SRC_DIR" && cd "$SRC_DIR"
if [ ! -d opencv ]; then git clone https://github.com/opencv/opencv.git; fi
git -C opencv fetch --tags && git -C opencv checkout "$VERSION"

CONTRIB_FLAG=""
if [ "$WITH_CONTRIB" = true ]; then
  if [ ! -d opencv_contrib ]; then git clone https://github.com/opencv/opencv_contrib.git; fi
  git -C opencv_contrib fetch --tags && git -C opencv_contrib checkout "$VERSION"
  CONTRIB_FLAG="-DOPENCV_EXTRA_MODULES_PATH=${SRC_DIR}/opencv_contrib/modules"
fi

# --- Configure ---
mkdir -p "${SRC_DIR}/opencv/build" && cd "${SRC_DIR}/opencv/build"
CUDA_FLAGS=(-DWITH_CUDA=OFF)
if [ "$WITH_CUDA" = true ]; then
  CUDA_FLAGS=(-DWITH_CUDA=ON -DWITH_CUDNN=ON -DOPENCV_DNN_CUDA=ON -DCUDA_ARCH_BIN="")
fi
cmake ../ \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DBUILD_EXAMPLES=OFF \
  -DBUILD_TESTS=OFF \
  -DBUILD_PERF_TESTS=OFF \
  -DOPENCV_GENERATE_PKGCONFIG=ON \
  -DINSTALL_PYTHON_EXAMPLES=OFF \
  ${CONTRIB_FLAG} \
  "${CUDA_FLAGS[@]}"

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
sudo ldconfig

echo "OpenCV $VERSION installed to /usr/local. Verify: python3 -c 'import cv2; print(cv2.__version__)'"
