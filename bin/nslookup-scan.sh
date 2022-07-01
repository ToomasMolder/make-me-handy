#!/bin/bash
###################################################################
# Script Name   : nslookup-scan.sh
# Script version: 1.0
# Script date   : 2022-07-01
# Description   : nslookup-scan of subnet
# Args          : [subnet]
# Author        : Toomas Mölder
# Email         : toomas.molder+nslookup@gmail.com
###################################################################
##
## Usage: nslookup-scan.sh [subnet]
## Sample: nslookup-scan.sh 127.0.0
##
## Options:
##   [subnet]      Optional, first 3 octests of IPv4 Class C (/24)
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
  echo "$0: Version "
  script_version=$(/bin/grep --no-messages "^# Script version[[:space:]]*:" "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  script_date=$(/bin/grep --no-messages "^# Script date[[:space:]]*:" "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  echo "${0} version: ${script_version} (${script_date})"
  exit $?
} 2>/dev/null

function debug() {
  if [ "${debug}" == "y" ]; then echo "DEBUG -- ${*}"; fi
} 2>/dev/null

# Test an IP address for validity
function valid_ip() {
  local  ip=${1}
  local  stat=1

  # if [[ ${ip} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
  if [[ ${ip} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=${IFS}
    IFS='.'
    # shellcheck disable=SC2206
    ip=(${ip})
    IFS=${OIFS}
    # [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 ]]
      stat=${?}
  fi
  return ${stat}
}

#
# MAIN
#
function main() {
  # Get subnets from arguments
  subnets="${*}"
  debug "Arguments: ${subnets}"

  # Handle lack of arguments
  if [ -z "${subnets}" ]; then
    debug "No arguments given"
	# get first 3 octets (identify the network) of all IP-addresses of current host
    subnets=$(hostname --all-ip-addresses)
    debug "SUBNETS is ${subnets}"
	unset octets
	for subnet in ${subnets}; do
          octets="${octets} $(echo "${subnet}" | cut --delimiter='.' --field=1-3)"
	done
	subnets="${octets}"
	debug "Set SUBNETS as ${subnets}"
  fi

  # Remove all duplicates
  subnets=$(echo "${subnets}" | xargs --max-args=1 | sort --unique | xargs)
  debug "SUBNETS is ${subnets}"

  range="1 254" # the host portion of the IP address
  for subnet in ${subnets}; do
    debug "Validating subnet ${subnet}"
    if valid_ip "${subnet}"; then 
      debug "$(basename "${0}" .sh) of ${subnet} in range of ${range}"
      # shellcheck disable=SC2086
	  for host in $(seq ${range}); do
        ipv4="${subnet}.${host}"
    	  fqdn=$(nslookup "${ipv4}" | /usr/bin/awk -F "=" '{ print $2 }' | /bin/sed --expression='s/^[[:blank:]]*//' | /bin/sed --expression='/^$/d' | /bin/sed --expression='s/.$//' | tr '\n' ' ')
        # Print only if nslookup returns result
        if [ -n "${fqdn}" ]; then
          echo "${ipv4} ${fqdn}"
        fi
	  done	
	else
	  debug "Incorrect subnet ${subnets}"
	  usage 2>&1
	fi
  done
}

while [ ${#} -gt 0 ]; do
  case ${1} in
  (-h|--help) usage 2>&1;;
  (-d|--debug) debug="y"; shift;;
  (-v|--version) version;;
  (-x|--xtrace) set -o xtrace; shift;;
  (--) shift; break;;
  (-*) usage "${*}: unknown option"; exit;;
  (*) break;;
  esac
done

# Do the main stuff
main "${@}"