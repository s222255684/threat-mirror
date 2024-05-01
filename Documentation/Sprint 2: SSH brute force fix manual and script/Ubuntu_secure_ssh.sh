#!/bin/bash

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install Fail2Ban
sudo apt-get install fail2ban -y

# Change SSH port and disable password authentication
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Restart SSH to apply changes
sudo systemctl restart ssh

# Configure Fail2Ban for SSH with basic settings
sudo tee /etc/fail2ban/jail.local > /dev/null <<EOL
[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
findtime = 600
bantime = 3600
EOL

# Restart Fail2Ban to apply changes
sudo systemctl restart fail2ban

echo "SSH and Fail2Ban configurations have been updated on your Ubuntu/Debian server."
