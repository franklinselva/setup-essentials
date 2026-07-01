#!/bin/bash

# Check if a distribution was specified
if [ "$1" == "" ]; then
    echo "Error: no distribution specified"
    exit 1
fi

# Set the ROS2 distribution
distribution=$1

# Remove the ROS 2 packages
sudo apt remove -y \
    ros-$distribution-desktop-full \
    ros-$distribution-ros-gz \
    ros-dev-tools \
    python3-argcomplete

# Remove the ROS 2 apt source (package + any leftover list)
sudo apt purge -y ros2-apt-source || true
sudo rm -f /etc/apt/sources.list.d/ros2.list /etc/apt/sources.list.d/ros2-latest.list

# Update the package list and remove any leftover dependencies
sudo apt update
sudo apt autoremove -y

# Remove the ROS2 environment variables from the bashrc file
sed -i '/# ROS2/d' ~/.bashrc
sed -i '/source \/opt\/ros\/.*\/setup.bash/d' ~/.bashrc

echo "ROS2 $distribution uninstalled successfully!"
