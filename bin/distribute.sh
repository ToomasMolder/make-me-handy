#!/bin/bash
###################################################################
# Script Name   : distribute.sh
# Script version: 1.25
# Script date   : 2022-01-25
# Description   : Distribute my settings and management scripts
#               : throughout my servers
# Author        : Toomas Mölder
# Email         : toomas.molder+distribute@gmail.com
###################################################################

# source=$(eval echo "~")
source="${HOME}"
# echo "source: ${source}"

# We assume the current / running script itself to be distributed as well
myself="${0}"
# echo "myself: ${myself}"

# Set up list of files to be distributed
dotfiles="${source}/.bash_profile ${source}/.bashrc ${source}/.bash_aliases ${source}/.vimrc ${source}/.screenrc"
# echo "dotfiles: ${dotfiles}"
htoprc="${HOME}/.config/htop/htoprc"
# echo "htoprc: ${htoprc}"

# Set up list of management scripts to be distributed
binfiles="${source}/bin/colours.sh ${source}/bin/highlight.sh ${source}/bin/update.sh ${source}/bin/journal.sh ${source}/bin/make_my.sh"
# echo "binfiles: ${binfiles}"

# Set up space-delimited list of my hosts, short host names, without DNS domain name
# ENV=""
# TLD=""
HOSTS=""

# .my_env to be gitignored ...
if [ -s "${source}"/.my_env ]; then
    # shellcheck disable=SC1091
    source "${source}"/.my_env
fi
# echo "ENV: ${ENV}"
# echo "TLD: ${TLD}"
if test -z "${HOSTS}"
then
    echo "Error: HOSTS is empty. Please fill within ${source}/.my_env or in script directly"
    exit 1
else
    echo "HOSTS: ${HOSTS}"
fi

# Current host
my_host=$(hostname --long)

cwd=$(pwd)

# Set up public/private keys to distribute
id_rsa=false

if [ ! -f "${HOME}/.ssh/id_rsa.pub" ] || [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "No public/private key pair available, generate ..."
    /usr/bin/ssh-keygen
fi

if [ -f "${HOME}/.ssh/id_rsa.pub" ] && [ -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "Public/private key pair exists, set temporary variable"
    id_rsa=true
fi

# Distribute
for destination in ${HOSTS}; do
    if [ "${destination}" != "${my_host}" ]; then
        echo "=== ${destination} ==="
        if [ "${id_rsa}" == true ]; then
            # echo "Just in case we try to distribute public key as well"
            /usr/bin/ssh-copy-id "${LOGNAME}"@"${destination}"
        else
            # echo "Hmmm, no public/private key pair available. Be prepared to enter your password ..."
            : # no-op
        fi
        # dotfiles
        /usr/bin/scp -p "${dotfiles}" "${destination}":
        # htoprc
        /usr/bin/ssh "${destination}" "mkdir --parents .config/htop/"
        # scp -p' Preserves modification times, access times, and modes from the original file.
        /usr/bin/scp -p "${htoprc}" "${destination}":.config/htop/
        # binfiles
        /usr/bin/ssh "${destination}" "mkdir --parents bin/"
        # scp -p' Preserves modification times, access times, and modes from the original file.
        /usr/bin/scp -p "${myself}" "${binfiles}" "${destination}":bin/
    fi
done
unset destination

cd "${cwd}" || exit