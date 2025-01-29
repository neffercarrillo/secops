# Save output to a file
$outputFile = "C:\Incident_Response_Report.txt"

# Collect basic system information
"### SYSTEM INFORMATION ###" | Out-File -FilePath $outputFile
(Get-WmiObject -Class Win32_ComputerSystem | Select-Object Name, Manufacturer, Model) | Out-File -FilePath $outputFile -Append
(Get-WmiObject -Class Win32_OperatingSystem | Select-Object Caption, Version, InstallDate) | Out-File -FilePath $outputFile -Append

# Collect user information
"### USER ACCOUNTS ###" | Out-File -FilePath $outputFile -Append
Get-LocalUser | Select-Object Name, Enabled, LastLogon | Out-File -FilePath $outputFile -Append

# Collect running processes
"### RUNNING PROCESSES ###" | Out-File -FilePath $outputFile -Append
Get-Process | Select-Object Name, Id, CPU, StartTime | Out-File -FilePath $outputFile -Append

# Collect network activity
"### NETWORK CONNECTIONS ###" | Out-File -FilePath $outputFile -Append
Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State | Out-File -FilePath $outputFile -Append

# Collect scheduled tasks
"### SCHEDULED TASKS ###" | Out-File -FilePath $outputFile -Append
Get-ScheduledTask | Select-Object TaskName, State | Out-File -FilePath $outputFile -Append

# Collect system logs
"### SYSTEM LOGS ###" | Out-File -FilePath $outputFile -Append
Get-WinEvent -LogName System -MaxEvents 100 | Out-File -FilePath $outputFile -Append

# Collect recently modified files
"### RECENTLY MODIFIED FILES ###" | Out-File -FilePath $outputFile -Append
Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -gt (Get-Date).AddDays(-7) } | Select-Object FullName, LastWriteTime | Out-File -FilePath $outputFile -Append

Write-Host "Incident response data saved to $outputFile"
