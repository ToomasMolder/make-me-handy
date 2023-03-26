#!/bin/bash
###################################################################
# Script Name   : colours.sh
# Script version: 1.07
# Script date   : 2022-02-12
# Description   : Foreground & background colour commands
# Usage         : source ./colours.sh
# Author        : Toomas Mölder
# Email         : toomas.molder+colours@gmail.com
###################################################################
#
# Initialize the terminal according to the type of terminal in the environmental variable TERM. 
if command -v tput &> /dev/null; then
  : # /usr/bin/tput init
else
  echo "ERROR: tput not available. No colour variables set"
  exit 1
fi

: '
# tput Color Capabilities:
tput setab [1-7]    # Set the background colour using ANSI escape
tput setb [1-7]     # Set a background color
tput setaf [1-7]    # Set the foreground colour using ANSI escape
tput setf [1-7]     # Set a foreground color

# tput Text Mode Capabilities:
tput bold           # Set bold mode
tput dim            # turn on half-bright mode
tput smul           # begin underline mode
tput rmul           # exit underline mode
tput rev            # Turn on reverse mode
tput smso           # Enter standout mode (bold on rxvt)
tput rmso           # Exit standout mode
tput sgr0           # Turn off all attributes

# Colours are as follows:
Num  Colour    #define         R G B
0    black     COLOR_BLACK     0,0,0
1    red       COLOR_RED       1,0,0
2    green     COLOR_GREEN     0,1,0
3    yellow    COLOR_YELLOW    1,1,0
4    blue      COLOR_BLUE      0,0,1
5    magenta   COLOR_MAGENTA   1,0,1
6    cyan      COLOR_CYAN      0,1,1
7    white     COLOR_WHITE     1,1,1

# Text mode commands
tput bold    # Select bold mode
tput dim     # Select dim (half-bright) mode
tput smul    # Enable underline mode
tput rmul    # Disable underline mode
tput rev     # Turn on reverse video mode
tput smso    # Enter standout (bold) mode
tput rmso    # Exit standout mode
'

unset black red green yellow blue magenta cyan white reset
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