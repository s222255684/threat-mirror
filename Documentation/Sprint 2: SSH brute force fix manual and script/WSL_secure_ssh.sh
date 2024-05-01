#!/bin/bash

# Install SSH and Fail2Ban
sudo apt-get update && sudo apt-get install -y openssh-server fail2ban

# Configure SSHD - Assume it's similar to Ubuntu/Debian
sudo sed -i 's/^#Port 22/Port 2222/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Start SSH service
sudo service ssh --full-restart

# Configure Fail2Ban for SSH
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

# Start Fail2Ban service
sudo service fail2ban restart

echo "SSH and Fail2Ban configurations have been updated on your Windows WSL."
