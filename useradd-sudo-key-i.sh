#!/bin/bash
#
# User add with sudo and ssh key - interactive
#
###############################################################

read -p "Enter username - " USERNAME
read -p "Paste public key - " PUBLIC_KEY

apt-get install sudo -y
sudo adduser --disabled-password --gecos "" $USERNAME
sudo usermod -aG sudo $USERNAME
sudo mkdir -p /home/$USERNAME/.ssh && sudo touch /home/$USERNAME/.ssh/authorized_keys
sudo chmod 700 /home/$USERNAME/.ssh && sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME /home/$USERNAME/.ssh
sudo sh -c "echo $PUBLIC_KEY > /home/$USERNAME/.ssh/authorized_keys"
sudo sh -c "echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME-user"
