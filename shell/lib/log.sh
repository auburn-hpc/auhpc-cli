#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  log.sh | 05.08.23
#  bootstrap\helper functions for script logfiles 
#  ---------------------------------------------------------

source colors.sh || return 1; logfile=${1}; 

if [[ -z ${logfile} ]] || [[ ! -e ${logfile} ]]; then
    printf "${ORANGE}warning${OFF}: logfile unset, redirecting file output to /dev/null\n" >&2
    logfile="/dev/null"
fi

# functions 

function begin-script() {
    stamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
    printf "\n--- BEGIN %s ---\n" ${stamp} >> ${logfile}
}

function end-script() {
    stamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
    printf "\nexecution ended, see %s for details\n\n" ${logfile} >&2
    printf "\n--- END %s ---\n" ${stamp} >> ${logfile}
}

function log-file() {
    local msg="${1}"
    local stamp=$(date +"%Y-%m-%dT%H:%M:%S%z")
    printf "%s:%s" ${stamp} "${msg}" >> ${logfile}
}

function log() {

    # usage: log [message-type] [message]

   local type="info"; [[ ! -z ${1} ]] && local type="${1}"
   local msg=( "${0}" ); [[ ! -z ${2} ]] && local msg=( "${2}" )
   
   [[ "${type}" == "blank" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { msg="\n"; printf "%b\n" "${msg}"; log-file "${msg}"; }
   [[ "${type}" == "error" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "error: %b\n\n" "${msg}" >&2; log-file "${msg}"; }
   [[ "${type}" == "fatal" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "${RED}error${BLK}:${OFF} %b. exiting.\n\n" "${msg}" >&2; log-file "${msg}"; script-end 1; }
   [[ "${type}" == "info" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "%b\n" "${msg}"; log-file "${msg}"; }
   [[ "${type}" == "sub" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "${YEL}%b${OFF}\n\n" "${msg}"; log-file "${msg}"; }
   [[ "${type}" == "head" ]]&& (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "\n${INFO}%b${OFF}\n\n" "${msg}"; log-file "${msg}"; }
   
   # configurable log entry types

   [[ "${type}" == "stderr" ]] && (( ${AUHPC_LOGLEVEL} > 0 )) && { printf "%b\n" "${msg}" >&2; log-file "${msg}"; }
   [[ "${type}" == "warn" ]] && (( ${AUHPC_LOGLEVEL} > 3 )) && { printf "${WARN}warning${OFF}: %b\n" "${msg}" >&2; log-file "${msg}"; }
   [[ "${type}" == "internal" ]] && (( ${AUHPC_LOGLEVEL} > 7 )) && { printf "%b\n\n" "${msg}" >&2; log-file "${msg}"; }
   [[ "${type}" == "dev" ]] && (( ${AUHPC_LOGLEVEL} > 8 )) && { printf "${SKY}${FUNCNAME[1]}${OFF}: %b\n" "${msg}" >&2; log-file "${msg}"; }

   return 0

}

