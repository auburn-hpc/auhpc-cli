#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  output.sh | 05.08.23
#  ---------------------------------------------------------

auhpc-header() {
    (( ${#} != 1 )) || [[ -z ${1} ]] && return 1
    auhpc-function-metadata "${1}" || return 1
    [[ -z ${fields[@]} ]] || [[ -z ${pads[@]} ]] && return 1
    for idx in $(seq 0 $(( ${#fields[@]}-1 ))); do
        printf "%-*s" ${pads[${idx}]} "${fields[${idx}]}"
    done
    printf "\n"
    return 0;
}

auhpc-columns() {
    (( ${#} == 0 )) || [[ -z "${1}" ]] && return 1
    local data=( "${@}" ); [[ -z ${data[@]} ]] && return 1
    auhpc-function-metadata "${1}" || return 1
    for idx in $(seq 1 $(( ${#data[@]}-1 ))); do
        printf "%-*s" ${pads[$(( ${idx}-1 ))]} ${data[${idx}]}
    done; printf "\n"; return 0;
}
