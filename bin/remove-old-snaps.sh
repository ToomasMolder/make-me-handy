#!/bin/bash
###################################################################
# Script Name   : remove-old-snaps.sh
# Script version: 1.01
# Script date   : 2022-01-22
# Description   : Remove old revisions of snaps to free up disk space
# Prerequisite  : /usr/bin/snap is available, installed
# Args          : <none>
# Author        : https://www.linuxuprising.com/2019/04/how-to-remove-old-snap-versions-to-free.html
# Email         : toomas.molder+makemehandy@gmail.com
###################################################################
## Remove old revisions of snaps to free up disk space
##
## Usage: ./remove-old-snaps.sh [options]
##
## Options:
##   -h, --help    Display this message
##   -d, --debug   Display debug messages
##   -v, --version Display version
##   -x, --xtrace  Print a trace of commands and their arguments
##                 before they are executed
##

function usage() {
  # [ "$*" ] && echo "$0: $*"
  /bin/sed --quiet '/^## /,/^$/s/^## \{0,1\}//p' "$0"
  exit $?
} 2>/dev/null

function version() {
  # [ "$*" ] && echo "$0: Version "
  # Use 'awk -F ' instead of 'awk --field-separator=' for backwards compatibility 
  SCRIPT_VERSION=$(/bin/grep --no-messages "^# Script version *: " "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  SCRIPT_DATE=$(/bin/grep --no-messages "^# Script date *: " "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  echo "${0} version: ${SCRIPT_VERSION} (${SCRIPT_DATE})"
  exit $?
} 2>/dev/null

function debug() {
  if [ "${DEBUG}" == "y" ]; then echo "$@"; fi
} 2>/dev/null

function main() {
  debug "Check xtrace."
  if [ "${XTRACE}" == "y" ]; then set -o xtrace; fi

  # Check snap available
  if [ ! -x /usr/bin/snap ]; then
    echo "ERROR: Snap is not available / executable"
    echo "snap can be installed from the Ubuntu Software Centre by searching for snapd"
    echo "Please do:"
    echo "    $ sudo apt update"
    echo "    $ sudo apt install snapd"
    exit 1
  fi
  # CLOSE ALL SNAPS BEFORE RUNNING THIS
  set -eu

  LANG=en_US.UTF-8 snap list --all | awk '/disabled/{print $1, $3}' |
    while read -r snapname revision; do
        sudo snap remove "$snapname" --revision="$revision"
    done

  exit $?
}

#
# MAIN
#

while [ $# -gt 0 ]; do
  case $1 in
  (-h|--help) usage 2>&1;;
  (-d|--debug) DEBUG="y"; shift;;
  (-v|--version) version 2>&1;;
  (-x|--xtrace) XTRACE="y"; set -o xtrace; shift;;
  (--) shift; break;;
  (-*) usage "$1: unknown option"; exit;;
  (*) break;;
  esac
done

# Do the main stuff
main