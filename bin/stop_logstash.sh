#!/bin/bash
###################################################################
# Script Name   : stop_logstash.sh
# Script version: 1.03
# Script date   : 2022-01-25
# Description   : Kill logstash, use before reboot
# Note          : Must run as root, through sudo or other power user
# Author        : Toomas Mölder
# Email         : toomas.molder+logstash@gmail.com
# Respect, tributes and thanks to: Vitali Stupin
###################################################################

set -e # Exit immediately if a command exits with a non-zero status.

# We assume that logstash user may run only "logstash" process
user="logstash"

check_stopped () {
    # Waiting for logstash to stop normally
    echo -n "Waiting for ${user} to stop"
    # We give logstash 30 seconds to flush data and stop
    for ((i=1;i<=10;i++)); do
        if /usr/bin/pgrep --count --uid "${user}" | /bin/grep --quiet '0'; then
            echo -e "\n${user} stopped"
            exit 0
        fi
        echo -n "."
        /bin/sleep 3
    done
    echo ""
}

# Stopping logstash without blocking to check when it stoppes (SIGTERM (15) signal from systemd)
/bin/systemctl --no-block stop "${user}"
check_stopped

# Sending SIGINT (2) signal to logstash for the first time (logstash will still try to shutdown gracefully)
/usr/bin/pkill --signal SIGINT --uid "${user}"
check_stopped

# Sending SIGINT (2) signal to logstash for the second time (logstash should terminate immediately with a failure)
# NB! This may result in data loss or duplicate data in elasticsearch
# But we assume that 2x30 seconds is enough to write changes to elasticsearch and sincedb
/usr/bin/pkill --signal SIGINT --uid "${user}"
check_stopped

echo "WARNING: Unable to kill ${user}."
exit 1