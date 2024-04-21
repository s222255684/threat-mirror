#!/bin/bash

# Update your system
apt-get update && apt-get upgrade -y

# Install Fail2Ban
apt-get install fail2ban -y

# Copy the default configuration file
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Change the default SSH port (Optional)
read -p "Enter a new SSH port number (default is 22, press Enter to skip): " ssh_port
if [[ ! -z "$ssh_port" ]]; then
    sed -i "s/^#Port 22/Port $ssh_port/" /etc/ssh/sshd_config
    echo "SSH port changed to $ssh_port. You must restart the SSH service for changes to take effect."
fi

# Configure Fail2Ban for SSH
cat >> /etc/fail2ban/jail.local <<EOL
[sshd]
enabled = true
port = $ssh_port
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOL

# Restart Fail2Ban and SSH services
systemctl restart fail2ban
service ssh restart

echo "Fail2Ban installation and configuration complete. SSH is now protected."
