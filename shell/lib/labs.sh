#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  labs.sh | 05.08.23
#  functions for cluster identity, resource state, and
#  job submission
#  ---------------------------------------------------------

function auhpc-lab-pi() {
    # lab name -> pi uid
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    sinfo -o "%g" 2>/dev/null | tr ',' '\n' | grep "_lab" | grep ${filter} | sed 's/_lab//g' | sort | uniq || return 1
    return 0
}

function auhpc-pi-labs() {
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    sinfo -o "%g" 2>/dev/null | tr ',' '\n' | grep "_lab" | grep ${filter} | sort | uniq || return 1
    return 0
}

function auhpc-pi-ids() {
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    sinfo -o "%g" 2>/dev/null | grep -oE "(^[a-z]{3,7}*[0-9]{3})[^_lab]" | \
      tr ' ' '\n' | grep -oE "(^[a-z]{3,7}*[0-9]{3})[^_lab]" | grep ${filter} || return 1
    return 0
}

function auhpc-pi-email() {
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    sinfo -o "%g" 2>/dev/null | tr ',' '\n' | grep -E "(^[a-z]{3,7}*[0-9]{3})[^_lab]" | \
      sort | uniq | sed 's/_lab/@auburn.edu/g' | grep ${filter} || return 1
    return 0
}

function auhpc-pi-info() {
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    [[ "${filter}" =~ "hpcadmin" ]] && { echo "HPC Admins <hpcadmin@auburn.edu>"; return 0; }
    local ids=( $(auhpc-pi-ids | grep ${filter}) )
    for id in ${ids[@]}; do 
        name=$(getent passwd ${id} 2>/dev/null | cut -d':' -f5 | tr -s ' ' | tr '\n' ' ' 2>/dev/null)
        (( ${?} != 0 )) || [[ -z ${name} ]] && continue;
        printf "%s<%s>\n" "${name}" $(auhpc-pi-email ${id})
    done || return 1
    return 0
}

function auhpc-id-mail() {
    printf "%s@auburn.edu" "${USER}"
}

function auhpc-id() {
    
    local name=$(getent passwd ${USER} 2>/dev/null | cut -d':' -f5 | tr -s ' ' | tr '\n' ' ' 2>/dev/null)
    local mail=$(auhpc-id-mail)
    local labs=( $(auhpc-id-labs) )

    printf "%s<%s>\n" "${name}" "${mail}"
    printf "Research Lab Access (%s):\n" ${#labs[@]}
    
    for lab in ${labs[@]}; do
        local pi=$(auhpc-lab-pi ${lab})
        local pi_data=$(auhpc-pi-info ${pi})
        local partitions=( $(auhpc-lab-partitions ${lab}) )
        
        printf "${SKY}%s${OFF}: ${GRY}PI: %s\n\n" "${lab}" "${pi_data}"

        local dedicated=()

        for partition in ${partitions[@]}; do
            auhpc-partition-class "${partition}" "dedicated" 2>&1 >/dev/null && dedicated+=( "${partition}" ) || continue;
        done

        printf "${YEL}%s${OFF} Dedicated Partitions:\n" ${#dedicated[@]}
        
        for partition in ${dedicated[@]}; do
            
            local type="$(auhpc-partition-type ${partition})"
            local cpu="$(auhpc-partition-cpu-type ${partition})"
            local gpu="$(auhpc-partition-gpu-type ${partition})"
            local nodes="$(auhpc-partition-nodes-total ${partition})"
            local cores="$( auhpc-partition-cores-total ${partition})"
            local mem="$(auhpc-partition-memory-total ${partition})"

            printf "${GRN}%s${OFF}: %s Nodes | %s Cores | %s Memory\n" "${partition}" "${nodes}" "${cores}" "${mem}"
            printf "%s Architecture: %s\n" "${type}" "${cpu}"
            printf "%s" "${gpu}"

        done

        printf "\n"

    done
    
}

function auhpc-id-labs() {
    groups 2>/dev/null | tr ' ' '\n' | grep "_lab" && return 0 || return 1 
}

function auhpc-lab-partitions() {
    local filter="${1}"; [[ -z ${filter} ]] && filter="."
    sinfo --noheader -o "%P %g" 2>/dev/null | grep "${filter}" | cut -d' ' -f1 || return 1
    return 0
}