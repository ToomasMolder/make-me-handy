#!/bin/bash
###################################################################
# Script Name   : make_my.sh
# Script version: 1.53
# Script date   : 2021-12-18
# Description   : Make my environment handy
# Args          : <none>
# Author        : Toomas Mölder
# Email         : toomas.molder+makemehandy@gmail.com
###################################################################
## Make my bash environment handy
##
## Usage: make_my.sh [options]
##
## Options:
##   -h, --help    Display this message
##   -d, --debug   Display debug messages
##   -t, --test    Update only .test
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

function my_source() {
  if [ "${DEBUG}" == "y" ]; then 
    echo "$@"; 
  fi
  to_be_sourced="${1}"
  if [ -f "${to_be_sourced}" ]; then
    # https://github.com/koalaman/shellcheck/wiki/SC1090
    # shellcheck source=/dev/null
    source "${to_be_sourced}"; 
    echo "${0}: Info: source ${to_be_sourced}"
  else 
    echo "${0}: Warning: file ${to_be_sourced} does not exist. Do nothing."
  fi
} 2>/dev/null


function update() {
  debug "Check parameters and files available"
  if [ $# -ne 2 ]; then echo "${0}: Warning: function ${FUNCNAME[0]}() MUST have EXACTLY two parameters, FROM and TO. Do nothing."; return; fi

  from="${1}"; to="${2}"

  if [ ! -s "${from}" ]; then echo "${0}: Warning: file ${from} does not exist or is empty. Do nothing."; return; fi

  debug "Get version and date"
  # Use 'awk -F ' instead of 'awk --field-separator=' for backwards compatibility 
  FROM_VERSION=$(/bin/grep --extended-regexp --no-messages "^[#\"] Script version *: " "${from}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  FROM_DATE=$(/bin/grep --no-messages "^[#\"] Script date *: " "${from}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  debug "${from}: version: ${FROM_VERSION} (${FROM_DATE})"
  TO_VERSION=$(/bin/grep --extended-regexp --no-messages "^[#\"] Script version *: " "${to}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  TO_DATE=$(/bin/grep --no-messages "^[#\"] Script date *: " "${to}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  debug "${to}: version: ${TO_VERSION} (${TO_DATE})"

  debug "Remove all new line, carriage return, tab characters \
    from the string, to allow integer / float comparison."
  FROM_VERSION="${FROM_VERSION//[$'\t\r\n ']}"
  FROM_DATE="${FROM_DATE//[$'\t\r\n ']}"
  TO_VERSION="${TO_VERSION//[$'\t\r\n ']}"
  TO_DATE="${TO_DATE//[$'\t\r\n ']}"
  debug "${from}: version: ${FROM_VERSION} (${FROM_DATE})"
  debug "${to}: version: ${TO_VERSION} (${TO_DATE})"

  debug "Check existence. If not, then give default value."
  if [ -z "${FROM_VERSION}" ]; then FROM_VERSION=0; fi
  if [ -z "${FROM_DATE}" ]; then FROM_DATE=1970-01-01; fi
  if [ -z "${TO_VERSION}" ]; then TO_VERSION=0; fi
  if [ -z "${TO_DATE}" ]; then TO_DATE=1970-01-01; fi
  debug "${from}: version: ${FROM_VERSION} (${FROM_DATE})"
  debug "${to}: version: ${TO_VERSION} (${TO_DATE})"

  debug "Make update happen only when newest version is not yet present."
  printf '==> %s' "${to}"
  if [ ! -s "${to}" ]; then
    /bin/cp --preserve "${from}" "${to}";
    echo " added to version ${FROM_VERSION} (${FROM_DATE}).";
    return;
  fi
  if (( $(echo "${FROM_VERSION} <= ${TO_VERSION}" | /usr/bin/bc --mathlib) && $(echo "$(/bin/date --date="${FROM_DATE} UTC" +%s) <= $(/bin/date --date="${TO_DATE} UTC" +%s)" | /usr/bin/bc --mathlib) )); then
    echo " version ${TO_VERSION} (${TO_DATE}) already exists. Did not update."
  else
    if [ -s "${to}" ]; then
      debug "Make backup of ${to} into ${to}.bak"
      /bin/cp --preserve "${to}" "${to}".bak;
      debug "Remove previous version from ${to} if exists, to avoid duplicate handys ..."
      /bin/sed --in-place '/^###################################################################$/,$d' "${to}"
      debug "Add newline to the end of ${to} if not present yet to avoid script errors."
      [ -n "$(tail --quiet --bytes=1 "${to}")" ] && printf '\n' >> "${to}";
    fi
    /bin/cat "${from}" >> "${to}";
    echo " updated from version ${TO_VERSION} (${TO_DATE}) to version ${FROM_VERSION} (${FROM_DATE})."
  fi
}

function main() {
  debug "Check xtrace."
  if [ "${XTRACE}" == "y" ]; then set -o xtrace; fi

  debug "Check script version and date."
  SCRIPT_VERSION=$(/bin/grep --no-messages "^# Script version *: " "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//' | /usr/bin/bc --mathlib)
  SCRIPT_DATE=$(/bin/grep --no-messages "^# Script date *: " "${0}" | /usr/bin/tail --lines 1 | /usr/bin/awk -F ':' '{print $2}' | /usr/bin/awk '{print $1}' | /bin/sed --expression='s/^[[:space:]]*//')
  debug "${0} version: ${SCRIPT_VERSION} (${SCRIPT_DATE})"

  if [ "${TEST}" == "y" ]; then
    update "${LOCALREPO}"/.my_test "${HOME}"/.test
  else
    update "${LOCALREPO}"/.my_profile "${HOME}"/.profile; 
    # my_source "${HOME}"/.profile
    update "${LOCALREPO}"/.my_bashrc "${HOME}"/.bashrc; 
    # my_source "${HOME}"/.bashrc
    update "${LOCALREPO}"/.my_bash_aliases "${HOME}"/.bash_aliases; 
    shopt -s expand_aliases
    my_source "${HOME}"/.bash_aliases
    update "${LOCALREPO}"/.my_vimrc "${HOME}"/.vimrc
    update "${LOCALREPO}"/.my_screenrc "${HOME}"/.screenrc

    # update "${LOCALREPO}"/.my_htoprc "${HOME}"/.config/htop/htoprc
    # Beware! This file is rewritten by htop when settings are changed in the interface.
    # The parser is also very primitive, and not human-friendly.
    # color_scheme=
    # Default = 0
    # Monochromatic = 1
    # Black on White = 2
    # Light Terminal = 3
    # MC = 4
    # Black Night = 5
    # Broken Gray = 6
    # I like Broken Gray, ie color_scheme=6
    if [ -f "${LOCALREPO}"/.my_htoprc ]; then
      printf '==> %s' "${HOME}"/.config/htop/htoprc
      /bin/mkdir --parents "${HOME}"/.config/htop
      if [ -f "${HOME}"/.config/htop/htoprc ]; then
          /bin/sed --in-place=.bak --expression='s/^color_scheme=.*$/color_scheme=6/' "${HOME}"/.config/htop/htoprc
      else
          /bin/cp --preserve "${LOCALREPO}"/.my_htoprc "${HOME}"/.config/htop/htoprc
      fi
      echo " color scheme updated."
    else
      echo "${0}: Warning: file ${LOCALREPO}/.my_htoprc does not exist. Do nothing."
    fi
  fi

  exit $?
}

#
# MAIN
#

REPO="make-me-handy"
# Repo was downloaded into "${HOME}"/"${REPO}", .my_ environment is under "${HOME}"/"${REPO}"/"${REPO}"
LOCALREPO="${HOME}"/"${REPO}"/"${REPO}"

while [ $# -gt 0 ]; do
  case $1 in
  (-h|--help) usage 2>&1;;
  (-d|--debug) DEBUG="y"; shift;;
  (-t|--test) TEST="y"; shift;;
  (-v|--version) version 2>&1;;
  (-x|--xtrace) XTRACE="y"; set -o xtrace; shift;;
  (--) shift; break;;
  (-*) usage "$1: unknown option"; exit;;
  (*) break;;
  esac
done

# Do the main stuff
main