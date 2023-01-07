#!/bin/bash

# Check if a distribution was specified
if [ "$1" == "" ]; then
    echo "Error: no distribution specified"
    exit 1
fi

# Set the ROS2 distribution
distribution=$1

# Add the ROS2 repository
sudo apt update && sudo apt install -y curl
curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64,arm64] http://packages.ros.org/ros2/ubuntu `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install ROS2 and dependencies
sudo apt update
sudo apt install -y \
    ros-$distribution-desktop \
    python3-argcomplete \
    build-essential \
    python3-colcon-common-extensions

# Install Gazebo
sudo apt install -y \
    ros-$distribution-gazebo-ros-pkgs \
    ros-$distribution-gazebo-ros-control

# Initialize the ROS2 environment
echo "source /opt/ros/$distribution/setup.bash" >> ~/.bashrc
source ~/.bashrc

echo "ROS2 $distribution and Gazebo installed successfully!"
