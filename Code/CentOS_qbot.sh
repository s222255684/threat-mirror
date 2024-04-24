#!/bin/bash

# Installing ClamAV
sudo yum install -y epel-release
sudo yum install -y clamav clamav-update

# Update ClamAV database
sudo freshclam

# Starting ClamAV
sudo systemctl start clamd@scan
sudo systemctl enable clamd@scan

# Configuring ClamAV
sudo sed -i '/^#ScanArchive/s/^#//' /etc/clamav/clamd.conf   # Enable scanning inside archives
sudo sed -i '/^#ScanPE/s/^#//' /etc/clamav/clamd.conf         # Enable scanning of PE files (Windows executables)
sudo sed -i '/^#ScanMail/s/^#//' /etc/clamav/clamd.conf       # Enable scanning of mail files
sudo sed -i '/^#PhishingSignatures/s/^#//' /etc/clamav/clamd.conf  # Enable phishing signatures
sudo sed -i '/^#HeuristicScanPrecedence/s/^#//' /etc/clamav/clamd.conf  # Enable heuristic scanning
sudo sed -i '/^#PhishingScanURLs/s/^#//' /etc/clamav/clamd.conf  # Enable phishing URL scanning
sudo sed -i '/^ExcludePath/s/^#//' /etc/clamav/clamd.conf   # Exclude specified paths from scanning (e.g., network shares)
sudo sed -i '/^#RemoveInfected/s/^#//' /etc/clamav/clamd.conf    # Remove infected files instead of moving to quarantine

# Restarting ClamAV to apply changescent
sudo systemctl restart clamd@scan

echo "Running ClamAV scan"
clamscan -r /  # Scan the entire filesystem recursively