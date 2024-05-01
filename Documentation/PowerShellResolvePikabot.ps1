# PowerShell script for detecting, removing, and preventing Pikabot Malware on Windows systems
#By default, Windows may prevent the execution of PowerShell scripts for security reasons. Open PowerShell as an Administrator and run ('Set-ExecutionPolicy RemoteSigned')

# Ensure the script runs with Administrator privileges
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "Please run this script as an Administrator!"
    Break
}

# Update Windows Defender signatures
Write-Host "Updating Windows Defender signatures..."
Update-MpSignature

# Perform a full system scan
Write-Host "Performing a full system scan..."
Start-MpScan -ScanType Full -ScanPath C:\

# Check scan results and remove threats
$Threats = Get-MpThreatDetection
If ($Threats)
{
    foreach ($Threat in $Threats)
    {
        Remove-MpThreat -ThreatId $Threat.ThreatID
        Write-Host "Removed threat: $($Threat.ThreatName)"
    }
}
else
{
    Write-Host "No threats found."
}

# Configure Firewall to block known malicious IPs or ports (example IPs/ports)
$BadIPs = "192.168.100.100", "10.0.0.200"
foreach ($IP in $BadIPs)
{
    New-NetFirewallRule -DisplayName "Block $IP" -Direction Outbound -Action Block -RemoteAddress $IP
    Write-Host "Firewall rule added to block traffic to $IP"
}

# Schedule daily scans using Task Scheduler
$Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command Start-MpScan -ScanType Full -ScanPath C:\"
$Trigger = New-ScheduledTaskTrigger -Daily -At 1am
Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName "Daily Defender Scan" -Description "Runs a daily full scan of the system using Windows Defender"

Write-Host "Daily scan task scheduled."
