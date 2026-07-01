# setup-essentials

Simple one-line installers to get a fresh **NVIDIA Jetson** or **Ubuntu** machine
ready for robotics work — ROS 2, cameras, Docker, OpenCV — without hunting through
scattered guides.

## Get started

Open a terminal and run:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/install.sh)
```

You'll see a menu — type the number of what you want to install and press Enter. That's it.

Prefer to skip the menu? Add the name of what you want to the same command:

```bash
# Install Docker on a Jetson
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/install.sh) jetson-docker

# Install ROS 2 Jazzy on regular Ubuntu
bash <(curl -sSL https://raw.githubusercontent.com/franklinselva/setup-essentials/main/install.sh) ubuntu-ros2 jazzy
```

## What you can install

### On a Jetson (JetPack 7.x / Ubuntu 24.04)

| Type this | What it sets up |
|-----------|-----------------|
| `jetson-ros2` | ROS 2 Jazzy (the robot software framework), ready to use |
| `jetson-realsense` | Intel RealSense depth camera support, with GPU acceleration |
| `jetson-docker` | Docker with GPU access — run containers that use the Jetson's CUDA |

### On any Ubuntu machine

| Type this | What it sets up |
|-----------|-----------------|
| `ubuntu-ros2 <version>` | ROS 2 for your Ubuntu (e.g. `ubuntu-ros2 jazzy`), with Gazebo |
| `ubuntu-ros2-uninstall <version>` | Removes a ROS 2 install |
| `ubuntu-ros2-humble-src` | Builds ROS 2 Humble from source |
| `ubuntu-depthai` | Luxonis / OAK camera support |
| `ubuntu-opencv` | OpenCV (computer vision library), latest version |

## Good to know

- **Jetson ROS 2** needs JetPack 7.x (Ubuntu 24.04). The installer checks this and stops early with a clear message if your board is on an older JetPack.
- **RealSense cameras** work straight after install — just unplug and replug the camera once so the permissions take effect.
- **Docker** is set up so containers can use the GPU automatically. Log out and back in once so you can run `docker` without `sudo`.
- **OpenCV** installs the newest release by default. If your project needs the older 4.x line, add `--version 4.11.0`. Add `--cuda` for GPU support (Jetson or a CUDA machine).

Each installer prints what to do next when it finishes.

---

<sub>Layout: `jetson/` and `ubuntu/` hold the installers, `common/` holds shared bits (camera rules, a license-header helper), and `install.sh` is the menu that ties them together.</sub>
