#!/bin/bash
###################################################################
# Script Name   : jdf.sh
# Script version: 1.01
# Script date   : 2023-03-08
# Description   : Tweaked disk usage sample
# Usage         : source ./jdf.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+jdf@gmail.com
###################################################################
##
## jdf - Copyleft 04/25/2009 - JPmicrosystems - GPL
## Free space on disk
## Custom df output
## Human readable (-h)
## sorted by file system name

# Checks command exists
function check_exists() {
  if ! command -v "${1}" &> /dev/null; then
    echo "Command ${1} could not be found. Please install it first."
	echo "$ sudo apt update && sudo apt upgrade"
    echo "$ sudo apt install ${1}	# Debian/Ubuntu"
    echo "$ sudo yum install ${1}	# RHEL/CentOS"
    echo "$ sudo dnf install ${1}	# Fedora 22+"
    exit
  fi
}

check_exists awk

## Make a temporary file and put the following awk program in it
AWK=$(mktemp --quiet /tmp/jdf.XXXXXX)

## PROG is quoted to prevent all shell expansions
## in the awk program
cat <<'PROG' > "${AWK}"
## Won't work if mount points are longer than 21 characters

BEGIN {
  ## Use fixed length fields to avoid problems with
  ## mount point or file system names with embedded blanks
  FIELDWIDTHS = "11 11 6 6 5 5 21"
  # printf "\n%s\n\n", "                    Available Disk Space"
  printf     "%s\n", "Mount Point          Avail Size  Used  Use%  Filesystem Type"
}

## Eliminate some filesystems
## That are usually not of interest
## anything not starting with a /

! /^\// { next }

## Rearrange the columns and print

{
  TYP=$2
  gsub("^ *", "", TYP)
  printf "%-21s%6s%6s%5s%5s %s%s\n", $7, $5, $3, $4, $6, $1, TYP
}

# END { print "" }
PROG

df --human-readable --print-type | tail --lines=+2 | sort | gawk --file "${AWK}"

rm --force "${AWK}"