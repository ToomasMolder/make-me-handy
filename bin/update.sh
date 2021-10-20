#!/bin/bash
###################################################################
# Script Name   : update.sh
# Script version: 1.02
# Script date   : 2021-07-25
# Description   : Update Ubuntu operating system
# Author        : Toomas Mölder
# Email         : toomas.molder+update@gmail.com
###################################################################

usage() {
    echo "Usage: ${0} [options]"
    echo "Options:"
    echo -e "-y|--yes|--assume-yes\tAutomatic yes to prompts.
    Assume 'yes' as answer to all prompts and run non-interactively.
    If an undesirable situation, such as changing a held package or removing an essential package, occurs then apt-get will abort."
    exit 0
    }

parameter=""
while test $# != 0
do
    case "${1}" in
    -y | --yes | --assume-yes)
        parameter="--assume-yes"
        ;;
    -h | --help | *)
        usage
        ;;
    esac
    shift
done

# man bash read  - https://linux.die.net/man/1/bash
# read -e - If the standard input is coming from a terminal, readline is used to obtain the line. Readline uses the current (or default, if line editing was not previously active) editing settings.
# read -r - If the -r option is present, the shell becomes restricted
# read -s - If the -s option is present, or if no arguments remain after option processing, then commands are read from the standard input. This option allows the positional parameters to be set when invoking an interactive shell.
# read -p prompt - Display prompt on standard error, without a trailing newline, before attempting to read any input. The prompt is displayed only if input is coming from a terminal.
# read -n nchars - read returns after reading nchars characters rather than waiting for a complete line of input, but honor a delimiter if fewer than nchars characters are read before the delimiter.
# read -t timeout - Cause read to time out and return failure if a complete line of input is not read within timeout seconds. timeout may be a decimal number with a fractional portion following the decimal point. This option is only effective if read is reading input from a terminal, pipe, or other special file; it has no effect when reading from regular files. If timeout is 0, read returns success if input is available on the specified file descriptor, failure otherwise. The exit status is greater than 128 if the timeout is exceeded.

declare -i timeout=5

sudo apt-get update ${parameter}
read -ersp "Press any key or wait ${timeout} seconds to continue... " -n 1 -t ${timeout}; echo
sudo apt-get dist-upgrade ${parameter}
read -ersp "Press any key or wait ${timeout} seconds to continue... " -n 1 -t ${timeout}; echo
sudo apt-get autoremove ${parameter}
read -ersp "Press any key to continue... " -n 1; echo
test -f /var/run/reboot-required && cat /var/run/reboot-required.pkgs 
read -ersp "Reboot now? Press Ctrl-C to cancel or any key to reboot now... " -n 1; history -a; sudo reboot now