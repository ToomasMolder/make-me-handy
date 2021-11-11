#!/bin/bash
###################################################################
# Script Name   : colours.sh
# Script version: 1.03
# Script date   : 2021-10-24
# Description   : Foreground & background colour commands
# Usage         : source ./colours.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+colours@gmail.com
###################################################################
#
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

black=$(tput setaf 0) || true
red=$(tput setaf 1) || true
green=$(tput setaf 2) || true
yellow=$(tput setaf 3) || true
blue=$(tput setaf 4) || true
magenta=$(tput setaf 5) || true
cyan=$(tput setaf 6) || true
white=$(tput setaf 7) || true
reset=$(tput sgr0) || true
export black red green yellow blue magenta cyan white reset