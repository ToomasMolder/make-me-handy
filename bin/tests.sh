#!/bin/bash

: <<'END'
# Can use a standard string comparison to compare the chronological ordering [of strings in a year, month, day format].
X="1970-01-01"
Y="2020-11-07"
echo "X = ${X}, Y = ${Y}"
if [[ "${X}" < "${Y}" ]]; then echo "${X} < ${Y}"; fi
if [[ "${X}" = "${Y}" ]]; then echo "${X} = ${Y}"; fi
if [[ "${X}" > "${Y}" ]]; then echo "${X} > ${Y}"; fi
X="2020-01-01"
Y="2020-01-01"
echo "X = ${X}, Y = ${Y}"
if [[ "${X}" < "${Y}" ]]; then echo "${X} < ${Y}"; fi
if [[ "${X}" = "${Y}" ]]; then echo "${X} = ${Y}"; fi
if [[ "${X}" > "${Y}" ]]; then echo "${X} > ${Y}"; fi
X="2020-01-02"
Y="2020-01-01"
echo "X = ${X}, Y = ${Y}"
if [[ "${X}" < "${Y}" ]]; then echo "${X} < ${Y}"; fi
if [[ "${X}" = "${Y}" ]]; then echo "${X} = ${Y}"; fi
if [[ "${X}" > "${Y}" ]]; then echo "${X} > ${Y}"; fi
X="0.0"
Y="1.0"
echo "X = ${X}, Y = ${Y}"
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \< ${Y#*.} ] || [ ${X%.*} -lt ${Y%.*} ]; then echo "${X} < ${Y}"; fi
if (( $(echo "${X} < ${Y}" | bc --mathlib) )); then echo "${X} < ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \= ${Y#*.} ] || [ ${X%.*} -eq ${Y%.*} ]; then echo "${X} = ${Y}"; fi
if (( $(echo "${X} = ${Y}" | bc --mathlib) )); then echo "${X} = ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \> ${Y#*.} ] || [ ${X%.*} -gt ${Y%.*} ]; then echo "${X} > ${Y}"; fi
if (( $(echo "${X} > ${Y}" | bc --mathlib) )); then echo "${X} > ${Y}"; fi
X="1.0"
Y="1.0"
echo "X = ${X}, Y = ${Y}"
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \< ${Y#*.} ] || [ ${X%.*} -lt ${Y%.*} ]; then echo "${X} < ${Y}"; fi
if (( $(echo "${X} < ${Y}" | bc --mathlib) )); then echo "${X} < ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \= ${Y#*.} ] || [ ${X%.*} -eq ${Y%.*} ]; then echo "${X} = ${Y}"; fi
if (( $(echo "${X} = ${Y}" | bc --mathlib) )); then echo "${X} = ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \> ${Y#*.} ] || [ ${X%.*} -gt ${Y%.*} ]; then echo "${X} > ${Y}"; fi
if (( $(echo "${X} > ${Y}" | bc --mathlib) )); then echo "${X} > ${Y}"; fi
X="1.0"
Y="1.01"
echo "X = ${X}, Y = ${Y}"
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \< ${Y#*.} ] || [ ${X%.*} -lt ${Y%.*} ]; then echo "${X} < ${Y}"; fi
if (( $(echo "${X} < ${Y}" | bc --mathlib) )); then echo "${X} < ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \= ${Y#*.} ] || [ ${X%.*} -eq ${Y%.*} ]; then echo "${X} = ${Y}"; fi
if (( $(echo "${X} = ${Y}" | bc --mathlib) )); then echo "${X} = ${Y}"; fi
# if [ ${X%.*} -eq ${Y%.*} ] && [ ${X#*.} \> ${Y#*.} ] || [ ${X%.*} -gt ${Y%.*} ]; then echo "${X} > ${Y}"; fi
if (( $(echo "${X} > ${Y}" | bc --mathlib) )); then echo "${X} > ${Y}"; fi
END

: <<'END'
user_agent="toomasm"
WGET_PARAMS="üks"
echo "${WGET_PARAMS}"
WGET_PARAMS="${WGET_PARAMS} kaks"
echo "${WGET_PARAMS}"

WGET_PARAMS="üks"
echo "${WGET_PARAMS}"
WGET_PARAMS=("${WGET_PARAMS}" "kaks")
END

# https://github.com/koalaman/shellcheck/wiki/SC2001
string="stirng" ; echo "${string//ir/ri}"
URL="https://ecyber-www.dev.riaint.ee"
URLS="${URL}"
for url in ${URLS}
do
    url_snipped=$(echo "${url}" | sed -e "s/https:\/\///g" | sed -e "s/http:\/\///g" | sed -e "s/:/_/g" | sed -e "s/\//_/g" | sed -e "s/_$//")
    echo "${url_snipped}"

    url_log=$(echo "${url_snipped}" | sed -e "s/$/\.log/")
    # See if you can use ${variable//search/replace} instead
    url_log="${url_snipped/%/\.log}"
    echo "${url_log}"
done
