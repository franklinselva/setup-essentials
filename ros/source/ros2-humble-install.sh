#!/bin/bash
# Install ROS2 humble from source

export DEBIAN_FRONTEND=noninteractive

# Set Locale
sudo apt update && sudo apt install locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# Add ros2 apt repository
sudo apt install -y software-properties-common
sudo add-apt-repository universe

sudo apt update && sudo apt install curl -y
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install development tools and ROS tools
sudo apt update && sudo apt install -y \
  python3-flake8-docstrings \
  python3-pip \
  python3-pytest-cov \
  ros-dev-tools

python3 -m pip install -U \
   flake8-blind-except \
   flake8-builtins \
   flake8-class-newline \
   flake8-comprehensions \
   flake8-deprecated \
   flake8-import-order \
   flake8-quotes \
   "pytest>=5.3" \
   pytest-repeat \
   pytest-rerunfailures

# Install ROS2 from source
mkdir -p /opt/ros/humble/src
cd /opt/ros/humble
sudo apt install python3-rosinstall-generator python3-rospkg
rosinstall_generator ros_base --deps --rosdistro humble | vcs pkg src

#Install dependencies from rosdep
sudo apt upgrade -y
sudo rosdep init
rosdep update
rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

cd /opt/ros/humble
colcon build --merge-install

# Setup environment
touch /opt/ros/humble/setup.bash
echo "source /opt/ros/humble/install/setup.bash" >> /opt/ros/humble/setup.bash

# Setup bashrc
echo "source /opt/ros/humble/setup.bash" >> $HOME/.bashrc
echo "export ROS_DISTRO=humble" >> $HOME/.bashrc
echo "export ROS_PYTHON_VERSION=3" >> $HOME/.bashrc

  
