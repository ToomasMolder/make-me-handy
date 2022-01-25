#!/bin/bash
###################################################################
# Script Name   : highlight.sh
# Script version: 1.02
# Script date   : 2022-01-25
# Description   : Highlight text on screen
# Author        : Toomas Mölder
# Email         : toomas.molder+highlight@gmail.com
###################################################################
#
# Usage: source ${HOME}/bin/highlight.sh
#
# Usage samples:
# /bin/cat in use but can be used through less, tail, more etc as well
#
# When MUST contain some TEXT, then highlight with green
# TEXT="some text"; /bin/cat FILE | /bin/egrep "${TEXT}" | highlight green "${TEXT}"
#
# Everything else but TEXT highlight with red
# TEXT="some text"; /bin/cat FILE | /bin/egrep --invert-match "${TEXT}" | highlight red "[-=:/_.\!()0-9A-Za-z]"

function highlight() {
	declare -A fg_color_map
	fg_color_map[black]=30
	fg_color_map[red]=31
	fg_color_map[green]=32
	fg_color_map[yellow]=33
	fg_color_map[blue]=34
	fg_color_map[magenta]=35
	fg_color_map[cyan]=36
	 
	fg_c=$(echo -e "\e[1;${fg_color_map[${1}]}m")
	c_rs=$'\e[0m'
	/bin/sed --unbuffered s"/${2}/${fg_c}\0${c_rs}/g"
}