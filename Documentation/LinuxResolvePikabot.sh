# Bash script for detecting, removing, and preventing Pikabot Malware on Linux

#!/bin/bash

# Define variables
LOGFILE="/var/log/pikabot-detection.log"
MALWARE_SIGNATURES="pikabot_signatures.db"
INFECTED_FILES="/tmp/infected_files.txt"

# Function to log activity
log_activity() {
    echo "$(date +"%Y-%m-%d %T") - $1" >> $LOGFILE
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update system and antivirus signatures
update_system() {
    log_activity "Updating the system and antivirus definitions..."
    apt-get update && apt-get upgrade -y
    freshclam
}

# Scan system for malware
scan_system() {
    log_activity "Scanning the system for Pikabot Malware..."
    clamscan -r --database=$MALWARE_SIGNATURES --infected --log=$LOGFILE --move=/quarantine /
}

# Remove malware artifacts
remove_malware() {
    if [[ -s $INFECTED_FILES ]]; then
        log_activity "Removing infected files..."
        while IFS= read -r file; do
            rm -f "$file"
            log_activity "Removed $file"
        done < "$INFECTED_FILES"
    else
        log_activity "No infected files found."
    fi
}

# Reinforce system security
secure_system() {
    log_activity "Securing the system against future infections..."
    # Install a firewall and enable it
    apt-get install ufw -y
    ufw enable
    ufw default deny incoming
    ufw default allow outgoing

    # Set up daily scans
    echo "0 1 * * * root clamscan -r --database=$MALWARE_SIGNATURES --move=/quarantine --log=$LOGFILE /" >> /etc/crontab

    # Harden ssh
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    systemctl restart sshd
}

# Create quarantine directory if not exists
[[ ! -d /quarantine ]] && mkdir /quarantine && log_activity "Created quarantine directory."

# Main program
main() {
    update_system
    scan_system
    remove_malware
    secure_system
    log_activity "Pikabot Malware detection and prevention script completed."
}

main
