#!/usr/bin/bash

# Output file
output_file="/tmp/incident_response_report.txt"

# Collect basic system information
echo "### SYSTEM INFORMATION ###" > $output_file
hostnamectl >> $output_file
echo >> $output_file

# Collect user information
echo "### USER ACCOUNTS ###" >> $output_file
awk -F: '{ print $1, $3, $6 }' /etc/passwd >> $output_file
echo >> $output_file

# Collect running processes
echo "### RUNNING PROCESSES ###" >> $output_file
ps aux >> $output_file
echo >> $output_file

# Collect network activity
echo "### NETWORK CONNECTIONS ###" >> $output_file
netstat -tuln >> $output_file
echo >> $output_file

# Collect scheduled tasks
echo "### CRON JOBS ###" >> $output_file
crontab -l >> $output_file 2>/dev/null
echo >> $output_file

# Collect system logs
echo "### SYSTEM LOGS ###" >> $output_file
journalctl -n 100 >> $output_file
echo >> $output_file

# Collect recently modified files
echo "### RECENTLY MODIFIED FILES ###" >> $output_file
find / -type f -mtime -7 2>/dev/null >> $output_file
echo >> $output_file

# Collect auditd logs (if auditd is installed)
if command -v auditctl &> /dev/null; then
    echo "### AUDITD STATUS ###" >> $output_file
    auditctl -s >> $output_file
    echo >> $output_file

    echo "### RECENT AUDIT LOGS ###" >> $output_file
    ausearch --start today -k suspicious >> $output_file
    echo >> $output_file

    echo "### RECENT LOGIN ATTEMPTS ###" >> $output_file
    ausearch -m USER_LOGIN --success yes --start today >> $output_file
    echo >> $output_file

    echo "### FILE ACCESS MONITORING ###" >> $output_file
    ausearch -m PATH --start today >> $output_file
    echo >> $output_file
else
    echo "auditd is not installed or running. Skipping auditd-related data." >> $output_file
    echo >> $output_file
fi

# Generate a summary of suspicious activities
if command -v aureport &> /dev/null; then
    echo "### AUDITD SUMMARY REPORT ###" >> $output_file
    aureport -l --start today >> $output_file
    echo >> $output_file
else
    echo "aureport is not available. Skipping summary report." >> $output_file
    echo >> $output_file
fi

echo "Incident response data saved to $output_file"
