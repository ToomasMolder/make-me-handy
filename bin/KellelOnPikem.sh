#!/bin/bash
# KellelOnPikem.sh
# Pärib AD-st kõigi kasutajate õigused ja leiab kellel
# on kõige rohkem õigusi.
# Kasutamine:
# source ./KellelOnPikem.sh
# Priit Parmakson
# 12.10.2022

# See also
# https://www.cyberciti.biz/faq/linux-list-all-members-of-a-group/
# man groups; man lid
	
getent passwd | cut -d: -f1 | \
while read in; do 

  ( id $in | \
    while read kasutaja grupid; do
      KP=$(echo $kasutaja | sed "s/uid=[[:digit:]]\+//g") ;
      GP=$(echo $grupid | sed "s/,/\n/g" | wc -l) ;
      echo $KP $GP 
    done; \
  )

done | sort --key 2 --numeric-sort --reverse