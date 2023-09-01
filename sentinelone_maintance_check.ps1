# Define the path where the installer will be saved
# Varible $SiteToken is a Syncro MSP platform varible
$supportFolder = 'C:\Support'
$installerPath = Join-Path $supportFolder 'SentinelAgent.exe'

# Import the Syncro PowerShell module
Import-Module $env:SyncroModule

# Check if SentinelOne is already installed and the service is running
$installationPath = 'C:\Program Files\SentinelOne'
$serviceStatus = Get-Service -Name SentinelAgent -ErrorAction SilentlyContinue

if (Test-Path $installationPath -and $serviceStatus.Status -eq 'Running') {
    Write-Host 'SentinelOne is already installed and the SentinelAgent service is running.'
    return
}

# Create a Syncro ticket for ThreatLocker installation
$ticketResult = Create-Syncro-Ticket -Subject "SentinelOne Installation - $DeviceName" -IssueType "Security" -Status "New"
#Add initial comment to ticket
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Initial Issue" -Body "SentinelOne not found on system." -Hidden "false" -DoNotEmail "true"
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Diagnosis" -Body "SentinelOne service not running on expected device. Need to verify installation." -Hidden "true" -DoNotEmail "true"


# Check if the C:\Support folder exists, and create it if it's missing
if (-not (Test-Path $supportFolder -PathType Container)) {
    Write-Host 'Creating support folder...'
    New-Item -ItemType Directory -Path $supportFolder | Out-Null
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Update" -Body "Support folder created. Location: C:\Support" -Hidden "true" -DoNotEmail "true"
}

# Install SentinelOne using the downloaded EXE file and the specified Site Token
Write-Host 'Installing SentinelOne...'
Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Update" -Body "SentinelOne installation started from file: $installerPath" -Hidden "true" -DoNotEmail "true"
$installerArguments = "-t $SiteToken -q"
Start-Process -FilePath $installerPath -ArgumentList $installerArguments -Wait

Write-Host 'Installation complete.'

# Wait for a moment to allow the service to start
Start-Sleep -Seconds 10

# Verify the installation
$serviceStatus = Get-Service -Name SentinelAgent -ErrorAction SilentlyContinue

if (Test-Path $installationPath -and $serviceStatus.Status -eq 'Running') {
    Write-Host 'SentinelOne installation verified.'
    $verifyNotes = "SentinelOne installation verified."
    $ticketStatus = "Resolved"
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Completed" -Body "SentinelOne installation completed and verified." -Hidden "true" -DoNotEmail "true"
}
}
else {
    Write-Host 'SentinelOne installation verification failed.'
    $verifyNotes = "ThreatLocker installation verification failed."
    $ticketStatus = "Customer Reply"
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Update" -Body "SentinelOne installation failed verification." -Hidden "true" -DoNotEmail "true"    
}
catch {
    Write-Output "Installation Failed."
    $verifyNotes = "SentinelOne installation verification failed."
    $ticketStatus = "Customer Reply"
    Create-Syncro-Ticket-Comment -TicketIdOrNumber $ticketResult.ticket.id -Subject "Update" -Body "SentinelOne installation failed verification." -Hidden "true" -DoNotEmail "true"
  }

# Add time entry with all notes for the entire process
Create-Syncro-Ticket-TimerEntry -TicketIdOrNumber $ticketResult.ticket.id -StartTime (Get-Date).ToString("o") -DurationMinutes 10 -Notes "SentinelOne Verification Status: $verifyNotes" -UserIdOrEmail "jack@westcomputers.com" -ChargeTime "true"
