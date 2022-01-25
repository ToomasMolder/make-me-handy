#!/bin/bash
###################################################################
# Script Name   : bin/journal.sh
# Script version: 1.2
# Script date   : 2022-01-25
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
vacuum_size="1G"
vacuum_time="6months"

#
# No more configuration settings below
#
# echo "Check out the current disk usage of all journal files"
/usr/bin/sudo /usr/bin/du --human /var/log/journal
/usr/bin/sudo /bin/journalctl --disk-usage
echo "Going to archive older than ${vacuum_time} and free up space more than ${vacuum_size}?"
read -r -p "Press Ctrl-C to cancel or any key to continue ... " -n1 -s
echo

# echo "Mark all currently active journal files as archived, so that they are never written to in future"
/usr/bin/sudo /bin/journalctl --rotate

# echo "Delete journal logs older than ${vacuum_time}"
/usr/bin/sudo /bin/journalctl --vacuum-time=${vacuum_time}

# echo "Delete log files until the disk space taken falls below the ${vacuum_size}"
/usr/bin/sudo /bin/journalctl --vacuum-size=${vacuum_size}

# echo "Check out the current disk usage of all journal files"
/usr/bin/sudo /bin/journalctl --disk-usage
/usr/bin/sudo /usr/bin/du --human /var/log/journal

echo
# echo "Configure journal to limit the disk usage up to ${vacuum_size}"
conf="/etc/systemd/journald.conf"
echo "Current value: $(/bin/grep "SystemMaxUse" ${conf})"
echo "Do you want to set limit to ${vacuum_size}?"
read -r -p "Press Ctrl-C to cancel or any key to continue ... " -n1 -s
echo

/usr/bin/sudo /bin/sed --in-place --expression="s/^#SystemMaxUse=$/SystemMaxUse=${vacuum_size}/g" ${conf}
echo "New value: $(/bin/grep "SystemMaxUse" ${conf})"
/usr/bin/sudo /bin/systemctl daemon-reload
echo "Systemctl daemon reloaded"