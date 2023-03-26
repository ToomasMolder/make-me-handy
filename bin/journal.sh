#!/bin/bash
###################################################################
# Script Name   : bin/journal.sh
# Script version: 1.3
# Script date   : 2023-01-16
# Description   : Control journal space in host
# Usage         : bin/journal.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+journal@gmail.com
###################################################################
#
# Inspiration: https://ubuntuhandbook.org/index.php/2020/12/clear-systemd-journal-logs-ubuntu/
# See also: https://man7.org/linux/man-pages//man1/journalctl.1.html
#
# New limits here
# vacuum_size="1G"
vacuum_size="500M"
# vacuum_time="6months"
vacuum_time="3months"

conf="/etc/systemd/journald.conf"
# log="/var/log/journal"

#
# No more configuration settings below
#
# echo "Check out the current disk usage of all journal files"
# sudo du --human "${log}"
sudo journalctl --disk-usage
echo "Going to archive older than ${vacuum_time} and free up space more than ${vacuum_size}?"
read -r -p "Press Ctrl-C to cancel or any key to continue ... " -n1 -s
echo

# echo "Mark all currently active journal files as archived, so that they are never written to in future"
sudo journalctl --rotate

# echo "Delete journal logs older than ${vacuum_time}"
sudo journalctl --vacuum-time=${vacuum_time}

# echo "Delete log files until the disk space taken falls below the ${vacuum_size}"
sudo journalctl --vacuum-size=${vacuum_size}

# echo "Check out the current disk usage of all journal files"
# sudo du --human "${log}"
sudo journalctl --disk-usage

echo
# echo "Configure journal to limit the disk usage up to ${vacuum_size}"
echo "Current value: $(/bin/grep "SystemMaxUse" ${conf})"
echo "Do you want to set limit to ${vacuum_size}?"
read -r -p "Press Ctrl-C to cancel or any key to continue ... " -n1 -s
echo

sudo sed --in-place --expression="s/^#SystemMaxUse=$/SystemMaxUse=${vacuum_size}/g" ${conf}
echo "New value: $(grep "SystemMaxUse" ${conf})"
sudo systemctl daemon-reload
echo "Systemctl daemon reloaded"