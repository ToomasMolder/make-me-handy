#!/bin/bash
###################################################################
# Script Name   : stop_logstash.sh
# Script version: 1.01
# Script date   : 2021-11-16
# Description   : Kill Logstash, use before Reboot
# Author        : Toomas Mölder
# Email         : toomas.molder+logstash@gmail.com
###################################################################

set -e # Exit immediately if a command exits with a non-zero status.

# NB! We assume that logstash user may run only "logstash" process!
user="logstash"

check_stopped () {
    # Waiting for logstash to stop normally
    echo -n "Waiting for ${user} to stop"
    # We give logstash 30 seconds to flush data and stop
    for i in {1..11}; do
        if /usr/bin/pgrep --count --uid ${user} | /bin/grep --quiet '0'; then
            echo -e "\n${user^} stopped"
            exit 0
        fi
        echo -n "."
        /bin/sleep 3
    done
    echo ""
}

# Stopping logstash without blocking to check when it stoppes (SIGTERM (15) signal from systemd)
sudo /bin/systemctl --no-block stop ${user}
check_stopped

# Sending SIGINT (2) signal to logstash for the first time (logstash will still try to shutdown gracefully)
sudo /usr/bin/pkill --signal SIGINT --uid ${user}
check_stopped

# Sending SIGINT (2) signal to logstash for the second time (logstash should terminate immediately with a failure)
# NB! This may result in data loss or duplicate data in elasticsearch
# But we assume that 2x30 seconds is enough to write changes to elasticsearch and sincedb
sudo /usr/bin/pkill --signal SIGINT --uid ${user}
check_stopped