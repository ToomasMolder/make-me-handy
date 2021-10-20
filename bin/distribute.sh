#!/bin/bash
###################################################################
# Script Name   : distribute.sh
# Script version: 1.24
# Script date   : 2021-10-11
# Description   : Distribute my settings and management scripts
#               : throughout my servers
# Author        : Toomas Mölder
# Email         : toomas.molder+distribute@gmail.com
###################################################################

# SOURCE=$(eval echo "~")
SOURCE="${HOME}"
# echo "SOURCE: ${SOURCE}"

# We assume the current / running script itself to be distributed as well
MYSELF="${0}"
# echo "MYSELF: ${MYSELF}"

# Set up list of files to be distributed
DOTFILES="${SOURCE}/.profile ${SOURCE}/.bashrc ${SOURCE}/.bash_aliases ${SOURCE}/.vimrc ${SOURCE}/.screenrc"
# echo "DOTFILES: ${DOTFILES}"
HTOPRC="${HOME}/.config/htop/htoprc"
# echo "HTOPRC: ${HTOPRC}"

# Set up list of management scripts to be distributed
BINFILES="${SOURCE}/bin/colours.sh ${SOURCE}/bin/highlight.sh ${SOURCE}/bin/update.sh ${SOURCE}/bin/journal.sh ${SOURCE}/bin/make_my.sh"
# echo "BINFILES: ${BINFILES}"

# Set up space-delimited list of my hosts, short host names, without DNS domain name
# ENV=""
# TLD=""
HOSTS=""
# Script version: 1.21 Script date   : 2021-04-15

# .my_env to be gitignored ...
if [ -s "${SOURCE}"/.my_env ]; then
    # shellcheck disable=SC1091
    # shellcheck source "${SOURCE}"/.my_env
    source "${SOURCE}"/.my_env
fi
# echo "ENV: ${ENV}"
# echo "TLD: ${TLD}"
if test -z "${HOSTS}"
then
    echo "Error: HOSTS is empty. Please fill within ${SOURCE}/.my_env or in script directly"
    exit 1
else
    echo "HOSTS: ${HOSTS}"
fi

# Current host
MY_HOST=$(hostname --long)

CWD=$(pwd)

# Set up public/private keys to distribute
id_rsa=false

if [ ! -f "${HOME}/.ssh/id_rsa.pub" ] || [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "No public/private key pair available, generate ..."
    ssh-keygen
fi

if [ -f "${HOME}/.ssh/id_rsa.pub" ] && [ -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "Public/private key pair exists, set temporary variable"
    id_rsa=true
fi

# Distribute
for destination in ${HOSTS}; do
    if [ "${destination}" != "${MY_HOST}" ]; then
        echo "=== ${destination} ==="
        if [ "${id_rsa}" == true ]; then
            # echo "Just in case we try to distribute public key as well"
            ssh-copy-id "${LOGNAME}"@"${destination}"
        else
            # echo "Hmmm, no public/private key pair available. Be prepared to enter your password ..."
            : # no-op
        fi
        # DOTFILES
        scp -p "${DOTFILES}" "${destination}":
        # HTOPRC
        ssh "${destination}" "mkdir --parents .config/htop/"
        # scp -p' Preserves modification times, access times, and modes from the original file.
        scp -p "${HTOPRC}" "${destination}":.config/htop/
        # BINFILES
        ssh "${destination}" "mkdir --parents bin/"
        # scp -p' Preserves modification times, access times, and modes from the original file.
        scp -p "${MYSELF}" "${BINFILES}" "${destination}":bin/
    fi
done

cd "${CWD}" || exit