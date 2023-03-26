#!/bin/bash
###################################################################
# Script Name   : distribute_my_id.sh
# Script version: 0.2
# Script date   : 2022-05-05
# Description   : Set up my SSH pub key throughout my hosts
#               : to enable password-less login between them
# Author        : Toomas Mölder
# Email         : toomas.molder+make-me-handy@gmail.com
###################################################################

# https://devops.ionos.com/tutorials/use-ssh-keys-with-putty-on-windows/
# Ensure "Public key for pasting into OpenSSH authorized_keys file" is replaced by actual :)
# mkdir --parents ~/.ssh; touch ~/.ssh/authorized_keys; chmod 600 ~/.ssh/authorized_keys; ### echo "Public key for pasting into OpenSSH authorized_keys file" >> ~/.ssh/authorized_keys; cat ~/.ssh/authorized_keys
if [ ! -f ~/.ssh/authorized_keys ]
then
    # echo "Add my key into ~/.ssh/authorized_keys"
	mkdir --parents ~/.ssh; 
	touch ~/.ssh/authorized_keys; 
	chmod 600 ~/.ssh/authorized_keys; 
	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHORxBxLeQniefAFKtysRSBeaYXwWGXdQPQtXCiosw/K toomasm@ria.ee" >> ~/.ssh/authorized_keys; 
	cat ~/.ssh/authorized_keys
	# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHORxBxLeQniefAFKtysRSBeaYXwWGXdQPQtXCiosw/K toomasm@ria.ee
else
    echo "File ~/.ssh/authorized_keys found. Do not do anything with it"
fi

echo "Exit immediately!" && exit

/*
sudo chmod +w /etc/sudoers
sudo vi /etc/sudoers
sudo chmod -w /etc/sudoers
sudo sh -c "echo '${SUDO_USER} ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo sh -c "echo '${SUDO_USER} ALL=(ALL:ALL) NOPASSWD:ALL' >> /etc/sudoers.d/10_sudo_users_groups"
*/

#
# NB! Allolevas sõltub edastava faili nimi valitud võtme tüübist!
# Küsida, parametriseerida!
#

# source=$(eval echo "~")
source="${HOME}"
# echo "source: ${source}"

# Set up my enviroment and top-level-domain for long hostnames
ENV=""
TLD=""
# Set up space-delimited list of my hosts, short host names, 
# without ENV.TLD name for more clarity
HOSTS=""

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
# Use short longname here instead of long
my_host=$(hostname --short)
# my_host=$(hostname --long)
# echo "my_host: ${my_host}"

cwd=$(pwd)

# Set up public/private keys to distribute
id_rsa=false
my_id_exists=false

# Please note, that files under different names are generated according to different type of key
# Not to be messed up, we do set -f ${HOME}/.ssh/my_id as file to keep it
my_id_file="${HOME}/.ssh/my_id"

if [ ! -f "${HOME}/.ssh/id_rsa.pub" ] || [ ! -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "No public/private key pair available, generate ..."
    # Use requirements for your company about -a rounds, -t type, -P passphrase, -f file, -C comment etc 
    /usr/bin/ssh-keygen -a 100 -t ed25519 -C "${USER}@{my_host}.${ENV}.${TLD}"
fi

if [ -f "${HOME}/.ssh/id_rsa.pub" ] && [ -f "${HOME}/.ssh/id_rsa" ]; then
    # echo "Public/private key pair exists, set temporary variable"
    my_id_exists=true
fi

# Distribute. Be smart and use short and long hostnames not mixed
destination=""
for destination in ${HOSTS}; do
    if [ "${destination}" != "${my_host}" ]; then
        echo "=== ${destination} ==="
        if [ "${id_rsa}" == true ]; then
            # echo "Distribute public key"
            # Vaata man ssh-copy-id, võti -i
            /usr/bin/ssh-copy-id "${LOGNAME}@${destination}.${ENV}.${TLD}"
        else
            # echo "Hmmm, no public/private key pair available. Be prepared to enter your password ..."
            : # no-op
        fi
    else
        # echo "Skipping ${destination} as my_host"
        : # no-op
    fi
done
unset my_id_exists 
unset source, destination
unset ENV, TLD, HOSTS, my_host

cd "${cwd}" || exit