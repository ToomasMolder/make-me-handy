#!/bin/bash
###################################################################
# Script Name   : replace.sh
# Script version: 0.9
# Script date   : 2023-01-03
# Description   : Find and replace by a given list of files
#               : Remove duplicate lines after that as well
# Args          : ${find_this} ${replace_with} ${path} [${path}]
# Author        : Toomas Mölder
# Email         : toomas.molder+makemehandy@gmail.com
###################################################################

find_this="${1}"
replace_with="${2}"
shift; shift

echo "find_this = ${find_this}"
echo "replace_with = ${replace_with}"
echo "rest = ${@}"

if command -v rg &>/dev/null ; then
  files=$(rg -l --color never "${find_this}" "${@}")
else
  files=$(ag -l --nocolor "${find_this}" "${@}")
fi

echo "files = ${files}"

tmp_file="${TMPDIR:-/tmp}/replace_tmp_file.$$"
IFS=$'\n'
for file in ${files}; do
  echo 'sed "s/${find_this}/${replace_with}/g" "${file}" | sort | uniq > "${tmp_file}" && mv "${tmp_file}" "${file}"'
  # sed "s/${find_this}/${replace_with}/g" "${file}" | sort | uniq > "${tmp_file}" && mv "${tmp_file}" "${file}"
done