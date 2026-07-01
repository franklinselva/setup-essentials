#!/bin/bash

# Check if a distribution was specified
if [ "$1" == "" ]; then
    echo "Error: no distribution specified"
    exit 1
fi

# Set the ROS2 distribution
distribution=$1

# Enable the Universe repository
sudo apt update && sudo apt install -y curl software-properties-common
sudo add-apt-repository -y universe

# Add the ROS 2 apt source (auto-updating repo config via ros2-apt-source .deb)
ROS_APT_SOURCE_VERSION=$(curl -s https://api.github.com/repos/ros-infrastructure/ros-apt-source/releases/latest | grep -F "tag_name" | awk -F\" '{print $4}')
curl -L -o /tmp/ros2-apt-source.deb \
    "https://github.com/ros-infrastructure/ros-apt-source/releases/download/${ROS_APT_SOURCE_VERSION}/ros2-apt-source_${ROS_APT_SOURCE_VERSION}.$(. /etc/os-release && echo "$VERSION_CODENAME")_all.deb"
sudo dpkg -i /tmp/ros2-apt-source.deb

# Install ROS 2 and dependencies
sudo apt update
sudo apt install -y \
    ros-$distribution-desktop-full \
    ros-dev-tools \
    python3-argcomplete

# Install Gazebo (Harmonic via ros_gz for Jazzy+; classic Gazebo is EOL)
sudo apt install -y ros-$distribution-ros-gz

# Initialize the ROS2 environment
echo "source /opt/ros/$distribution/setup.bash" >> ~/.bashrc
source ~/.bashrc

echo "ROS2 $distribution and Gazebo installed successfully!"
