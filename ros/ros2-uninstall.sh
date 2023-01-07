#!/bin/bash

# Check if a distribution was specified
if [ "$1" == "" ]; then
    echo "Error: no distribution specified"
    exit 1
fi

# Set the ROS2 distribution
distribution=$1

# Remove the ROS2 packages
sudo apt remove -y \
    ros-$distribution-desktop \
    python3-argcomplete \
    build-essential \
    python3-colcon-common-extensions \
    ros-$distribution-gazebo-ros-pkgs \
    ros-$distribution-gazebo-ros-control

# Remove the ROS2 repository
sudo rm /etc/apt/sources.list.d/ros2-latest.list
sudo apt-key del 421C365BD9FF1F717815A3895523BAEEB01FA116

# Update the package list and remove any leftover dependencies
sudo apt update
sudo apt autoremove -y

# Remove the ROS2 environment variables from the bashrc file
sed -i '/# ROS2/d' ~/.bashrc
sed -i '/source \/opt\/ros\/.*\/setup.bash/d' ~/.bashrc

echo "ROS2 $distribution uninstalled successfully!"
