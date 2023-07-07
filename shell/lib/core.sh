#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  core.sh | 05.08.23
#  environment, help, and metadata variables & functions
#  ---------------------------------------------------------

TRUNK="$(readlink -f $(dirname ${BASH_SOURCE}))" && [[ -L "${TRUNK}/etc/env" ]] && source "${TRUNK}/etc/env" 2>&1 >/dev/null 

#[[ ! "$0" =~ "${BASH_SOURCE[0]}*" ]] && { printf "\ndo not run directly: use \e[1m${TRUNK}/start\e[0m\n\n"; exit 1; }
[[ ! $_ != $0 ]] && { printf "\ndo not run directly: use \e[1m${TRUNK}/start\e[0m\n\n"; exit 1; }
[[ -z ${AUHPC_LIBPATH} ]] && { printf "\ninvalid environment, try: ${MAG}source .auhpc${OFF} for cluster use, ${MAG}module load auhpc${OFF}\n\n"; return 1; }
[[ ! -e ${AUHPC_LIBPATH} ]] && { printf "\ninvalid library path \"${AUHPC_LIBPATH}\", try: module load auhpc-cluster-tools\n\n"; return 1; }
[[ -z ${AUHPC_LOGLEVEL} ]] && export AUHPC_LOGLEVEL=4

function auhpc-validate-environment() {
    if [[ -z ${AUHPC_LIBPATH} ]]; then
        path="$(readlink -f $(dirname ${BASH_SOURCE[0]}))" #|| { \
        #printf "\n\e[38;5;214mERROR\e[0m: Unable to locate source files.
        #Check environment. Exiting.\n\n" >&2; return 1; }
        printf "\n\e[38;5;214mwarning\e[0m: AUHPC_LIBPATH undefined, 
        using: \e[38;5;27m%s\e[0m\nEnvironment settings may not be valid.\n" ${path} >&2
        export AUHPC_LIBPATH=${path}
    elif [[ ! -e ${AUHPC_LIBPATH} ]]; then
        printf "\n\e[38;5;214merror\e[0m: AUHPC_LIBPATH (%s) is invalid. 
        Check environment.\n\n" ${AUHPC_LIBPATH} >&2; return 1
    else return 0; fi
}

function auhpc-source() {
    (( ${#} > 0 )) && auhpc-validate-environment || return 1
    (( ${AUHPC_LOGLEVEL} > 3 )) && local out=1 || local out=0
    local scripts=( "${@}" ); for script in ${scripts[@]}; do
        local file=$(basename $(printf "%s.sh" "${script//.sh}"))
        local path="${AUHPC_LIBPATH}/${file}"
        [[ ! -e ${path} ]] && { (( ${out} == 1 )) && printf "FAIL\n" >&2; return 1; }
        (( ${out} == 1 )) && printf "sourcing %s ... " "${path}" >&2
        source ${path} 2>/dev/null && { local result="OK\n"; (( ${out} == 1 )) && printf "${result}\n"; return 0; } || { local result="FAIL\n"; return 1; } 
    done; return 0;
}

# set an environment variable, includes validation checks, etc.
function auhpc-env-set() {
    (( ${#} != 2 )) && return 1
    auhpc-validate-environment || return 1
    local var="${1}"; local value="${@:2}"
    export ${var}="${value}" 2>&1 >/dev/null && return 0 || return 1
}

# same as auhpc-env-set but only for null variables
function auhpc-env-setnull() {
    (( ${#} != 2 )) && return 1
    auhpc-validate-environment && auhpc-source log || return 1
    local var="${1}"; local value="${@:2}"
    env | grep -E "^${var}=." 2>&1 >/dev/null && return 0 || \
        log warn "setting undefined library environment variable: ${var}=${value}"
        export ${var}="${value}" 2>&1 >/dev/null && return 0 || return 1
}

 auhpc-source colors function || {
     printf "\n\e[38;5;214merror\e[0m: unable to locate library source file(s) in %s.\n\n" ${AUHPC_LIBPATH} >&2; return 1; }

[[ -z ${AUHPC_SETNAME} ]] && export AUHPC_SETNAME="AUIVS-HPC Shell Development Library"     
printf "\n${GRN}${AUHPC_SETNAME}: Environment Ready${OFF}.\n\n" ${AUHPC_LIBPATH} >&2;
