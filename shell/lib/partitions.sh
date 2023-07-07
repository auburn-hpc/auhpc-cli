#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  partitions.sh | 05.08.23
#  functions for cluster identity, resource state, and
#  job submission
#  ---------------------------------------------------------

function auhpc-partition-validate() {
    (( ${#} == 0 )) && return 1 
    sinfo -s -o "%P" | grep -E "^${1}[\*]?$" 2>&1 >/dev/null || return 1
    return 0
}

function auhpc-partition-memory-min() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local mem=$(sinfo --noheader -p "${1}" -o "%e" | cut -d'-' -f1 2>/dev/null) || return 1
    local memmin=$(( ${mem}/1000+1 2>/dev/null )) || return 1
    printf "%d GB" ${memmin}; return 0
}

function auhpc-partition-memory-max() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local mem=$(sinfo --noheader -p "${1}" -o "%e" | cut -d'-' -f2 2>/dev/null) || return 1
    local memmax=$(( ${mem}/1000+1 )) 2>/dev/null || return 1
    printf "%d GB" ${memmax}; return 0
}

function auhpc-partition-cores-total() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local cores=$(sinfo --noheader -s -p "${1}" -o "%C" | awk -F'/' '{print $NF}' 2>/dev/null) || return 1
    printf "%d" ${cores}; return 0
}

function auhpc-partition-cores-allocated() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local cores=$(sinfo --noheader -s -p "${1}" -o "%C" | awk -F'/' '{print $1}' 2>/dev/null) || return 1
    printf "%d" ${cores}; return 0
}

function auhpc-partition-cores-idle() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local cores=$(sinfo --noheader -s -p "${1}" -o "%C" | awk -F'/' '{print $2}' 2>/dev/null) || return 1
    printf "%d" ${cores}; return 0
}

function auhpc-partition-cpu-sockets() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local sockets=$(sinfo --noheader -p "${1}" -o "%X" 2>/dev/null) || return 1
    printf "%d" ${sockets}; return 0
}

function auhpc-partition-cpu-socket-cores() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local cores=$(sinfo --noheader -p "${1}" -o "%Y" 2>/dev/null) || return 1
    printf "%d" ${cores}; return 0
}

function auhpc-partition-cpu-sockets-cores-total() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local cores=$(sinfo --noheader -p "${1}" -o "%c" 2>/dev/null) || return 1
    printf "%d" ${cores}; return 0
}

function auhpc-partition-nodes-total() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local nodes=$(sinfo --noheader -s -p "${1}" -o "%D" 2>/dev/null) || return 1
    printf "%d" ${nodes}; return 0
}

function auhpc-partition-node-memory-total() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local mem=$(sinfo --noheader -s -p "${1}" -o "%m" 2>/dev/null | cut -d '/' -f1) || return 1
    local total=$(( ${mem}/1000+1 )) 2>/dev/null || return 1
    printf "%d" ${total}; return 0
}

function auhpc-partition-memory-total() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local mem=$(auhpc-partition-node-memory-total "${1}") || return 1
    local nodes=$(auhpc-partition-nodes-total "${1}") || return 1
    local memtotal=$(( (${mem}*${nodes})+1 )) 2>/dev/null || return 1
    printf "%d GB" ${memtotal}; return 0
}

function auhpc-partition-nodes-allocated() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local nodes=$(sinfo --noheader -s -p "${1}" -o "%A" 2>/dev/null | cut -d '/' -f1) || return 1
    printf "%d GB" ${nodes}; return 0
}

function auhpc-partition-nodes-idle() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local nodes=$(sinfo --noheader -s -p "${1}" -o "%A" 2>/dev/null | cut -d'/' -f2) || return 1
    printf "%d" ${nodes}; return 0
}

function auhpc-partition-class() {
    
    (( ${#} == 0 )) && return 1
    local filter="${2}"; [[ -z ${filter} ]] && filter="."

    local partition="${1}"
    
    [[ "${partition}" =~ (nova) ]] && class="community"
    [[ ! "${partition}" =~ ^[a-z][nova_]+?[^_]*$ ]] && class="dedicated"
    [[ "${partition}" =~ ^investor_* ]] && class="investor"
    [[ -s ${class} ]] && class="research"
    
    [[ "${filter}" == "${class}" ]] && printf "%s" "${class}" && return 0
    
    return 1

}

function auhpc-partition-type() {
    
    (( ${#} == 0 )) && return 1; local partition="${1}"; local type="Standard"

    [[ "${partition}" =~ "_bg2" ]] || [[ "${partition}" =~ "_bg4" ]] && type="Expanded"
    [[ "${partition}" =~ "_gpu2" ]] || [[ "${partition}" =~ "_gpu4" ]] && type="GPU"
    [[ "${partition}" =~ "_amd" ]] && type="Special"
    [[ "${partition}" =~ "nova" ]] && type+="Legacy"

    echo ${type} 

}

function auhpc-lab-cores() {
    local labs=( $(auhpc-id-labs) ); local data=()
    for lab in ${labs[@]}; do
        partitions=( $(auhpc-lab-partitions ${lab}) )
        for partition in ${partitions[@]}; do
            data=( $(sinfo --noheader -s -p ${partition} -o "%P %D %C" | tr '/' ' ') )
            printf "%s %d %d\n" "${data[0]}" ${data[1]} ${data[2]}
        done || return 1
    done
    return 0
}

function auhpc-partition-max-core() {
    [[ "${1}" =~ (-v|--verbose) ]] && auhpc-header ${FUNCNAME}
    local target=( $(auhpc-lab-cores | sort -k2 -n -r) )
    auhpc-columns "${FUNCNAME}" "${target[0]}" "${target[1]}" "${target[2]}"
    (( ${?} != 0 )) || [[ -z core_data ]] && return 1
}

function auhpc-partition-split-core() {
    [[ "${1}" =~ (-v|--verbose) ]] && auhpc-header ${FUNCNAME}
    local target=( $(auhpc-partition-max-core) ) || return 1
    local size=$(( ${target[2]} / ${target[1]} ))
    auhpc-columns ${FUNCNAME} "${target[0]}" ${size} ${target[2]} ${target[1]}
    (( ${?} != 0 )) || [[ -z core_data ]] && return 1
}

