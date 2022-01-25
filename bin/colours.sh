#!/bin/bash
###################################################################
# Script Name   : colours.sh
# Script version: 1.05
# Script date   : 2022-01-25
# Description   : Foreground & background colour commands
# Usage         : source ./colours.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+colours@gmail.com
###################################################################
#
# Initialize the terminal according to the type of terminal in the environmental variable TERM. 
if [ -x /usr/bin/tput ]; then
   : # /usr/bin/tput init
else
   echo "WARNING: tput not available"
fi

: '
Foreground & background colour commands
tput setab [1-7] # Set the background colour using ANSI escape
tput setaf [1-7] # Set the foreground colour using ANSI escape
Colours are as follows:

Num  Colour    #define         R G B
0    black     COLOR_BLACK     0,0,0
1    red       COLOR_RED       1,0,0
2    green     COLOR_GREEN     0,1,0
3    yellow    COLOR_YELLOW    1,1,0
4    blue      COLOR_BLUE      0,0,1
5    magenta   COLOR_MAGENTA   1,0,1
6    cyan      COLOR_CYAN      0,1,1
7    white     COLOR_WHITE     1,1,1

Text mode commands
tput bold    # Select bold mode
tput dim     # Select dim (half-bright) mode
tput smul    # Enable underline mode
tput rmul    # Disable underline mode
tput rev     # Turn on reverse video mode
tput smso    # Enter standout (bold) mode
tput rmso    # Exit standout mode
'

black=$(/usr/bin/tput setaf 0) || true
red=$(/usr/bin/tput setaf 1) || true
green=$(/usr/bin/tput setaf 2) || true
yellow=$(/usr/bin/tput setaf 3) || true
blue=$(/usr/bin/tput setaf 4) || true
magenta=$(/usr/bin/tput setaf 5) || true
cyan=$(/usr/bin/tput setaf 6) || true
white=$(/usr/bin/tput setaf 7) || true
reset=$(/usr/bin/tput sgr0) || true
export black red green yellow blue magenta cyan white reset