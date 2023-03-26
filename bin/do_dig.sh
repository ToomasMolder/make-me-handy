#!/bin/bash
###################################################################
# Script Name   : do_dig.sh
# Script version: 0.99
# Script date   : 2022-12-06
# Description   : dig DNS about available IP on IP spaces
# Usage         : source ./do_dig.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+do_dig@gmail.com
###################################################################
#
# If fails on error ...
set -e
# If pipe fails ...
# set -o pipefail
set -euo pipefail

third_octet_of_my_project="12"
# Define IP spaces ...
dev="10.1.${third_octet_of_my_project}"; 
test="10.2.${third_octet_of_my_project}"; 
demo_prod="10.4.${third_octet_of_my_project}";

# Echo ip ...
show_ip() {
  echo "${1}"
}

# Dig stuff ...
dig_stuff() {
  dig +short -x $(show_ip "${1}")."${i}" | sed "s/.$//";
}

# Dig specific ...
dig_specific() {
  if [[ -n $(dig_stuff "${1}") ]]; then
    echo -n "$(show_ip ${1})".${i}"; ";
    dig_stuff "${1}";
  else
    echo -n "";
  fi
}

# Execute sub dig ...
do_dig() {
  for i in {1..255}
    do
        dig_specific "${1}"; dig_specific "${2}"; dig_specific "${3}";
    done
}

# Do the main stuff, ie Go and dig ...
do_dig "${dev}" "${test}" "${demo_prod}";