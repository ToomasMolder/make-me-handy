#!/bin/bash

PID=$$
echo "First PID = ${PID}"

SS=10

# https://gist.github.com/jpclipffel/0b8f470be029fc9e3f07
# https://tobru.ch/follow-up-bash-script-locking-with-flock/
# https://dev.to/rrampage/ensuring-that-a-shell-script-runs-exactly-once-3d3f
# https://blog.famzah.net/2013/07/31/using-flock-in-bash-without-invoking-a-subshell/
# https://man7.org/linux/man-pages/man1/flock.1.html
[ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" || :

echo "Second PID = ${PID}"
echo "${PID}: Sleep ${SS}"
sleep ${SS}
echo "${PID}: Slept ${SS}"
