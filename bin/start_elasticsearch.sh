#!/bin/bash
###################################################################
# Script Name   : start_elasticsearch.sh
# Script version: 1.0
# Script date   : 2022-05-15
# Description   : Prevent elasticsearch systemd service start operation from timing out
# Note          : Must run as root, through sudo or other power user
# Author        : Toomas Mölder
# Email         : toomas.molder+elasticsearch@gmail.com
# Respect, tributes and thanks to: https://sleeplessbeastie.eu/2020/02/29/how-to-prevent-systemd-service-start-operation-from-timing-out/
###################################################################

set -e # Exit immediately if a command exits with a non-zero status.

# We assume that elasticsearch user may run only "elasticsearch" process
user="elasticsearch"
service="${user}.service"

check_stopped () {
    # Waiting for service to stop normally
    echo -n "Waiting for ${service} to stop "
    # We give 30 seconds to flush data and stop
    for ((i=1;i<=10;i++)); do
        if /usr/bin/pgrep --count --uid "${user}" | /bin/grep --quiet '0'; then
            echo -e "\n${service} stopped"
            return 0
        fi
        echo -n "."
        sleep 3
    done
    echo ""
}

# What do we have currently?
echo "Current timeouts for ${service}"
systemctl show ${service} | grep "^Timeout"

# TODO
# When Timeout satisfies, then ask about continuing

#
# FIRST, we STOP the service first
#
echo "Info: Stopping ${service} without blocking to check when it stoppes (SIGTERM (15) signal from systemd)"
sudo systemctl --no-block stop "${service}"
# check_stopped # We run it in next step according to style suggested by shellcheck SC2181

# Sending SIGINT (2) signal to user for the first time (service will still try to shutdown gracefully)
if ! check_stopped; then
    echo "Warning: ${service} not stopped yet."
	echo "Info: Sending SIGINT (2) signal to user ${user} for the first time (service will still try to shutdown gracefully)"
    sudo /usr/bin/pkill --signal SIGINT --uid "${user}"
    check_stopped
fi

# Sending SIGINT (2) signal to user for the second time (service should terminate immediately with a failure)
# NB! This may result in data loss or duplicate data in service
# But we assume that 2x30 seconds is enough to write changes to service and sincedb
# shellcheck disable=SC2181 # ignore style, do not want to run function check_stopped() again
if [ $? -ne 0 ]; then
    echo "Warning: ${service} still not stopped."
	echo "Info: Sending SIGINT (2) signal to user ${user} for the second time (service should terminate immediately with a failure)"
    sudo /usr/bin/pkill --signal SIGINT --uid "${user}"
    check_stopped
fi

# shellcheck disable=SC2181 # ignore style, do not want to run function check_stopped() again
if [ $? -ne 0 ]; then
    echo "ERROR: Unable to stop ${service} / kill ${user}"
    exit 1
fi

#
# SECOND, we configure service start timeout more than default 75 sec
#
echo "Info: Create a service drop-in configuration directory"
sudo mkdir --parents "/etc/systemd/system/${service}.d"

echo "Info: Define TimeoutStartSec option to increase startup timeout"
echo -e "[Service]\nTimeoutStartSec=300" | sudo tee "/etc/systemd/system/${service}.d/timeoutstart.conf"

echo "Info: Reload systemd manager configuration"
sudo systemctl daemon-reload

echo "Info: Inspect altered timeout for start operation"
systemctl show ${service} | grep "^Timeout"

#
# THIRD, we start ${service}
#
echo "Info: Start ${service}"
sudo systemctl start ${service}

echo "Info: Inspect ${service} status"
systemctl status ${service}