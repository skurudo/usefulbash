#!/bin/bash
#
# User add with sudo and ssh key - command line parameters
#
# ./useradd-sudo-key-p.sh "username" "public_key"
###############################################################

USERNAME=$1
PUBLIC_KEY=$2

echo "Username - " $USERNAME
echo "Paste public key - " $PUBLIC_KEY
echo "............................................" 

sudo adduser --disabled-password --gecos "" $USERNAME
sudo usermod -aG sudo $USERNAME
sudo mkdir -p /home/$USERNAME/.ssh && sudo touch /home/$USERNAME/.ssh/authorized_keys
sudo chmod 700 /home/$USERNAME/.ssh && sudo chmod 600 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME /home/$USERNAME/.ssh
sudo sh -c "echo $PUBLIC_KEY > /home/$USERNAME/.ssh/authorized_keys"
sudo sh -c "echo '$USERNAME ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/$USERNAME-user"
