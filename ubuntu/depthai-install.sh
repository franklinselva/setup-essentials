#!/bin/bash
# Install DepthAI / Luxonis OAK dependencies via the upstream depthai-ros script.
set -euo pipefail

curl -fsSL https://raw.githubusercontent.com/luxonis/depthai-ros/main/install_dependencies.sh | sudo bash
