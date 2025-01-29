# Set Output File
$outputFile = "C:\Initial_Response_Report.txt"

# Define Sysinternals Live Path
$sysinternalsLive = "\\live.sysinternals.com\tools"

# Create Report Header
"### INCIDENT RESPONSE REPORT ###" | Out-File -FilePath $outputFile
"Report generated on $(Get-Date)" | Out-File -FilePath $outputFile -Append
Add-Content -Path $outputFile -Value "`n"

# Basic System Information
"### SYSTEM INFORMATION ###" | Out-File -FilePath $outputFile -Append
(Get-WmiObject -Class Win32_ComputerSystem | Select-Object Name, Manufacturer, Model) | Out-File -FilePath $outputFile -Append
(Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, InstallDate) | Out-File -FilePath $outputFile -Append

# User Information
"### USER ACCOUNTS ###" | Out-File -FilePath $outputFile -Append
Get-LocalUser | Select-Object Name, Enabled, LastLogon | Out-File -FilePath $outputFile -Append

# Running Processes (via Sysinternals Process Explorer Live)
"### RUNNING PROCESSES ###" | Out-File -FilePath $outputFile -Append
Start-Process -FilePath "$sysinternalsLive\procexp.exe" -ArgumentList "/accepteula /save C:\ProcessList.txt" -Wait
Get-Content "C:\ProcessList.txt" | Out-File -FilePath $outputFile -Append
Remove-Item "C:\ProcessList.txt"

# Autorun Entries (via Sysinternals Autoruns Live)
"### AUTORUN ENTRIES ###" | Out-File -FilePath $outputFile -Append
Start-Process -FilePath "$sysinternalsLive\autorunsc.exe" -ArgumentList "/accepteula /nobanner /xml C:\Autoruns.xml" -Wait
Get-Content "C:\Autoruns.xml" | Out-File -FilePath $outputFile -Append
Remove-Item "C:\Autoruns.xml"

# Network Connections (via Sysinternals TCPView Live)
"### NETWORK CONNECTIONS ###" | Out-File -FilePath $outputFile -Append
Start-Process -FilePath "$sysinternalsLive\tcpvcon.exe" -ArgumentList "/accepteula" -RedirectStandardOutput "C:\TcpView.txt" -Wait
Get-Content "C:\TcpView.txt" | Out-File -FilePath $outputFile -Append
Remove-Item "C:\TcpView.txt"

# Verify File Integrity (via Sysinternals SigCheck Live)
"### FILE INTEGRITY CHECK ###" | Out-File -FilePath $outputFile -Append
Start-Process -FilePath "$sysinternalsLive\sigcheck.exe" -ArgumentList "/accepteula -e -c C:\SigCheck.csv" -Wait
Get-Content "C:\SigCheck.csv" | Out-File -FilePath $outputFile -Append
Remove-Item "C:\SigCheck.csv"

# Recent Logon Events
"### RECENT LOGON EVENTS ###" | Out-File -FilePath $outputFile -Append
Get-WinEvent -LogName Security -FilterXPath "*[System[EventID=4624]]" | Select-Object TimeCreated, Message | Out-File -FilePath $outputFile -Append

# Recent File Modifications
"### RECENTLY MODIFIED FILES ###" | Out-File -FilePath $outputFile -Append
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } | Select-Object FullName, LastWriteTime | Out-File -FilePath $outputFile -Append

Write-Host "Incident response data saved to $outputFile"
