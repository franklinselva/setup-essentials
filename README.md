# setup-essentials

Curl-able setup scripts for dev machines and Jetson boards.

## Jetson (JetPack 7.x / Ubuntu 24.04, arm64)

| Script | Installs | Method |
|--------|----------|--------|
| `jetson/ros2-jazzy-install.sh` | ROS 2 Jazzy desktop | apt binary, `ros-jazzy-desktop` + `ros-dev-tools` |
| `jetson/install-librealsense.sh` | Intel RealSense SDK 2.0 | Source build, RSUSB backend + CUDA |

```bash
# ROS 2 Jazzy
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/jetson/ros2-jazzy-install.sh)

# librealsense
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/jetson/install-librealsense.sh)
```

- **Jazzy** requires Ubuntu 24.04 (noble) = JetPack 7.x; the script aborts on any other codename. Uses the `ros2-apt-source` package (auto-updating apt source); the old `apt-key` method is removed (deprecated since Ubuntu 22.04).
- **RealSense** builds from source (`realsenseai/librealsense`) with the RSUSB backend — no kernel patch or DKMS, since the L4T kernel is not a mainline Ubuntu kernel. CUDA on by default (`--no_cuda` to disable).

## ROS 2 (generic Ubuntu)

| Script | Target | Method |
|--------|--------|--------|
| `ros/ros2-install.sh <distro>` | Any Ubuntu with matching ROS 2 distro | apt binary, `desktop-full` + `ros_gz` |
| `ros/source/ros2-humble-install.sh` | Build Humble from source | colcon |
| `ros/ros-noetic-install.sh` | ROS 1 Noetic | apt binary |

## Sensors / IO

| Script | Target | Method |
|--------|--------|--------|
| `io/realsense/build-librealsense.sh` | Jetson Nano (legacy, JetsonHacks) | Source build |
| `io/build-depthai.sh` | DepthAI / OAK cameras | — |
