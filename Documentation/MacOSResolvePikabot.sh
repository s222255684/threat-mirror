# Bash script for detecting, removing, and preventing Pikabot Malware on MacOS
# ClamAV may not be installed by default and may require installation via Homebrew ('brew install clamav')

#!/bin/bash

# Define variables
LOGFILE="/var/log/pikabot-detection.log"
MALWAREDB="/usr/local/share/clamav/pikabot_signatures.db"

# Function to log activity
log_activity() {
    echo "$(date +"%Y-%m-%d %T") - $1" >> $LOGFILE
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Update ClamAV and system software
update_system() {
    log_activity "Updating system and ClamAV databases..."
    clamav --update
    softwareupdate --install --all
}

# Scan system for malware
scan_system() {
    log_activity "Scanning the system for Pikabot Malware..."
    clamscan -r --database=$MALWAREDB --infected --log=$LOGFILE --move=/quarantine /
}

# Secure the system
secure_system() {
    log_activity "Securing the system..."
    # Configure pfctl to block known bad IPs (example setup)
    echo "block out quick from any to 192.168.100.100" >> /etc/pf.conf
    pfctl -e -f /etc/pf.conf
    log_activity "Updated pfctl rules to block known malicious IPs."

    # Set up a daily scan with launchd
    cat << EOF > /Library/LaunchDaemons/com.daily.clamscan.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.daily.clamscan</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/clamscan</string>
        <string>-r</string>
        <string>--database=$MALWAREDB</string>
        <string>--log=$LOGFILE</string>
        <string>--move=/quarantine</string>
        <string>/</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>1</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
EOF
    launchctl load /Library/LaunchDaemons/com.daily.clamscan.plist
    log_activity "Scheduled daily malware scan with launchd."
}

# Execute the functions
update_system
scan_system
secure_system
log_activity "Pikabot malware management script completed."
