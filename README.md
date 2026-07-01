# setup-essentials

Curl-able setup scripts for dev machines and Jetson boards.

## ROS 2

| Script | Target | Method |
|--------|--------|--------|
| `ros/ros2-jazzy-jetson-install.sh` | Jetson, JetPack 7.x / Ubuntu 24.04 (noble, arm64) | apt binary, `ros-jazzy-desktop` + `ros-dev-tools` |
| `ros/ros2-install.sh <distro>` | Any Ubuntu with matching ROS 2 distro | apt binary, `desktop-full` + `ros_gz` |
| `ros/source/ros2-humble-install.sh` | Build Humble from source | colcon |
| `ros/ros-noetic-install.sh` | ROS 1 Noetic | apt binary |

Repo config uses the `ros2-apt-source` package (auto-updates the apt source). The old `apt-key` method is removed — deprecated since Ubuntu 22.04.

Jazzy requires Ubuntu 24.04 (noble). On Jetson that means JetPack 7.x; the Jazzy script aborts on any other codename.

### Install ROS 2 Jazzy on a Jetson

```bash
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/ros/ros2-jazzy-jetson-install.sh)
```
