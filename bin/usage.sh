#!/bin/bash
###################################################################
# Script Name   : usage.sh
# Script version: 0.1
# Script date   : 2021-01-17
# Description   : Test usage cases
# Args          : <none>
# Author        : Toomas Mölder
# Email         : toomas.molder@gmail.com
###################################################################
##
## Usage: usage.sh [options]
##
## Options:
##   -h, --help    Display this message
##   -d, --debug   Display debug messages
##   -v, --version Display version
##   -x, --xtrace  Print a trace of commands and their arguments
##                 before they are executed
##

function usage() {
  [ "$*" ] && echo "$0: $*"
  /bin/sed --quiet '/^## /,/^$/s/^## \{0,1\}//p' "$0"
  exit $?
} 2>/dev/null

function version() {
  [ "$*" ] && echo "$0: Version "
  SCRIPT_VERSION=$(/bin/grep --no-messages "^# Script version *: " ${0} | /usr/bin/tail --lines 1 | /usr/bin/awk --field-separator=':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  SCRIPT_DATE=$(/bin/grep --no-messages "^# Script date *: " ${0} | /usr/bin/tail --lines 1 | /usr/bin/awk --field-separator=':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  echo "${0} version: ${SCRIPT_VERSION} (${SCRIPT_DATE})"
  exit $?
} 2>/dev/null

function debug() {
  if [ "${DEBUG}" == "y" ]; then echo "$@"; fi
} 2>/dev/null


#
# MAIN
#

while [ $# -gt 0 ]; do
  case $1 in
  (-h|--help) usage 2>&1;;
  (-d|--debug) DEBUG="y"; shift;;
  (-t|--test) TEST="y"; shift;;
  (-v|--version) version 2>&1;;
  (-x|--xtrace) XTRACE="y"; set -o xtrace; shift;;
  (--) shift; break;;
  (-*) usage "$@: unknown option"; exit;;
  (*) break;;
  esac
done

# Do the main stuff
main
