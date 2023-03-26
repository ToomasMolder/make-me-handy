#!/bin/bash
###################################################################
# Script Name   : lvm.sh
# Script version: 0.9
# Script date   : 2023-02-10
# Description   : HDD management
# Author        : Toomas Mölder
# Email         : toomas.molder+lvm@gmail.com
###################################################################

# ssh ${targetName}							# Specify target host FQDN or IP
# See also: https://bitbucket.ria.ee/projects/DEVOPS/repos/automation-infra/browse/terraform/Jenkinsfile.disk.management

# Set up parameters
# Specify device name
# If empty, default value is "/dev/sdb". 
# See https://help.ubuntu.com/lts/installation-guide/amd64/apcs04.html
defaultdeviceName="/dev/sdb"
deviceName="${defaultdeviceName}"
[[ -z "${deviceName}" ]] && read -p "Specify device name (default '${defaultdeviceName}'): " deviceName
[[ -z "${deviceName}" ]] && deviceName="${defaultdeviceName}"

# Set logical volume group name, use your own context
# If empty, default value is "data". 
# Volume group "${lvgName}" to be created
defaultlvgName="data"
lvgName="${defaultlvgName}"
[[ -z "${lvgName}" ]] && read -p "Set logical volume group name, use your own context (default '${defaultlvgName}'): " lvgName
[[ -z "${lvgName}" ]] && lvgName="${defaultlvgName}"

# Set logical volume name, use your own context
# Logical volume "${lvName}" to be created
# Samples: postgresql | www | backup | ...
defaultlvName="www"
lvName="${defaultlvName}"
[[ -z "${lvName}" ]] && read -p "Set logical volume name, use your own context (default '${defaultlvName}'): " lvName
[[ -z "${lvName}" ]] && lvName="${defaultlvName}"

# Set mountpath, use your own context.
# Mount point for logical volume.
# Samples: /var/lib/postgresql | /var/www | /srv/backup | ...
mountPath="/var/${lvName}"

# Set logical volume partitional size in natural number with suffix
# Samples: 10G 		# will create 10 Gigabyte space, or 
#          100%FREE	# full size of volume
lvSize="100%FREE"
defaultlvSize="100%FREE"
lvSize="${defaultlvSize}"
[[ -z "${lvSize}" ]] && read -p "Set logical volume partitional size in natural number with suffix (default '${defaultlvSize}'): " lvSize
[[ -z "${lvSize}" ]] && lvSize="${defaultlvSize}"

# Final check
if [ -z "${deviceName}" ] || \
   [ -z "${lvgName}" ] || \
   [ -z "${lvName}" || \
   [ -z "${mountPath}" || \
   [ -z "${lvSize}" ]; then
    echo "ERROR: One or more variables are undefined"
    exit 1
fi

$ df --human; echo; lsblk						# What do we have? When "${deviceName}" is missing, not taken into use, then ...
$ sudo pvcreate "${deviceName}"					# Create physical volume
$ sudo vgcreate "${lvgName}" "${deviceName}"	# Create volume group
$ sudo lvcreate --extents "${lvSize}" \
  --name "${lvName}" "${lvgName}"				# Create logical volume
$ sudo mkfs.ext4 "/dev/${lvgName}/${lvName}"	# Create file system
$ echo "/dev/${lvgName}/${lvName} \
  ${mountPath} ext4 defaults 0 2" | \
  sudo tee --append /etc/fstab					# Set up mount point
$ sudo mkdir --parents "${mountPath}"			# Create mount point directory if missing
$ sudo mount --all								# Mount additional HDD
$ df --human									# Review everything OK