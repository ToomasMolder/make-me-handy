#!/bin/bash
###################################################################
# Script Name   : stop_logstash.sh
# Script version: 1.04
# Script date   : 2022-05-15
# Description   : Kill logstash, use before reboot
# Note          : Must run as root, through sudo or other power user
# Author        : Toomas Mölder
# Email         : toomas.molder+logstash@gmail.com
# Respect, tributes and thanks to: Vitali Stupin
###################################################################

set -e # Exit immediately if a command exits with a non-zero status.

# We assume that logstash user may run only "logstash" process
user="logstash"
service="${user}.service"

check_stopped () {
    # Waiting for service to stop normally
    echo -n "Waiting for ${user} to stop"
    # We give user 30 seconds to flush data and stop
    for ((i=1;i<=10;i++)); do
        if pgrep --count --uid "${user}" | /bin/grep --quiet '0'; then
            echo -e "\n${user} stopped"
            exit 0
        fi
        echo -n "."
        sleep 3
    done
    echo ""
}

# Stopping service without blocking to check when it stoppes (SIGTERM (15) signal from systemd)
sudo systemctl --no-block stop "${service}"
check_stopped

# Sending SIGINT (2) signal to user for the first time (service will still try to shutdown gracefully)
sudo pkill --signal SIGINT --uid "${user}"
check_stopped

# Sending SIGINT (2) signal to user for the second time (service should terminate immediately with a failure)
# NB! This may result in data loss or duplicate data in service
# But we assume that 2x30 seconds is enough to write changes to service and sincedb
sudo pkill --signal SIGINT --uid "${user}"
check_stopped

echo "ERROR: Unable to stop ${service} / kill ${user}"
exit 1