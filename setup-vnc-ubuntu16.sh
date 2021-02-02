#!/bin/bash

# Update repos
sudo apt update

# Install XFCE4
echo "----Install Xubuntu-desktop"
sudo apt install xfce4 xfce4-goodies -y

echo "----Install VNC Server"
# Verify if vnc server is installed
dpkg -s "tightvncserver"|grep "Status: install ok installed" > /dev/null 2>&1
if [[ $? == 1 ]]
        then
                apt install tightvncserver -y
        else
                echo "Already installed"
fi

echo "----Run vncserver"
vncserver

echo "----Allow external connects by allowing ports in ufw"
sudo ufw allow 5901/tcp

# Create systemd file
echo "----Create Startup Script"
cat <<EOF > /etc/systemd/system/vncserver@.service
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=root
PAMName=login
PIDFile=/root/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1280x800 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl enable vncserver@1.service
echo "----Time to reboot!"

# Now you can reboot your machine