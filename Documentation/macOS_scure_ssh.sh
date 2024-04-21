#!/bin/bash

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Step 1: Disable SSH root login
echo "Disabling root login via SSH..."
sudo sed -i '' 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Step 2: Change the default SSH port
read -p "Enter a new SSH port number (default is 22, press Enter to skip): " ssh_port
if [[ ! -z "$ssh_port" ]]; then
    sudo sed -i '' "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
    echo "SSH port changed to $ssh_port."
fi

# Step 3: Limit SSH access to specific users
read -p "Enter the username who is allowed SSH access: " username
if [[ ! -z "$username" ]]; then
    echo "AllowUsers $username" | sudo tee -a /etc/ssh/sshd_config > /dev/null
    echo "SSH access is limited to user: $username"
fi

# Step 4: Configure the macOS firewall
echo "Configuring macOS firewall..."
# Enable the firewall
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
# Allow SSH only if a custom port is specified
if [[ ! -z "$ssh_port" ]]; then
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add tcp $ssh_port
else
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add tcp 22
fi

# Restart SSH service
echo "Restarting SSH service..."
sudo launchctl stop com.openssh.sshd
sudo launchctl start com.openssh.sshd

echo "SSH configuration and firewall settings have been updated."
