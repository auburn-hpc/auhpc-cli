#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  nodes.sh | 05.08.23
#  functions for cluster identity, resource state, and
#  job submission
#  ---------------------------------------------------------

function auhpc-node-gpu-count() {
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1
    local gpus=$(sinfo --noheader -s -p ${1} -o "%G" | awk -F':' '{print $NF}' 2>/dev/null) || gpus=0
    printf "%d" ${gpus} 2>/dev/null; return 0
}

function auhpc-partition-gpu-type() {

    (( ${#} == 1 )) && auhpc-partition-validate "${1}" && [[ "${1}" =~ "gpu" ]] || return 1

    local gpus=$(auhpc-node-gpu-count "${1}")
    local gpu_easley="Nvidia Tesla T4"
    local gpu_nova="Tesla K80"
    
    [[ "${partition}" =~ "_gpu2" ]] && type="${gpus}x ${gpu_easley}"
    [[ "${partition}" =~ "_gpu4" ]] && type="${gpus}x ${gpu_easley}"
    [[ "${partition}" =~ "nova_gpu" ]] && type="${gpus}x ${intel_nova20} ${gpu_nova}"

    printf "%s" "${type}" 2>/dev/null; return 0

}

function auhpc-partition-cpu-type() {
    
    (( ${#} == 0 )) && return 1 
    auhpc-partition-validate "${1}" || return 1

    local partition="${1}"
    local sockets=$(auhpc-partition-cpu-sockets "${1}")
    local cores=$(auhpc-partition-cpu-socket-cores "${1}")
    local intel_easley="Intel(R) Xeon(R) Gold 6248R CPU @ 3.00GHz [${sockets}x Sockets, ${cores} Cores/Socket]"
    local intel_nova20="Intel(R) Xeon(R) CPU E5-2660 v3 @ 2.60GHz [${sockets}x Sockets, ${cores} Cores/Socket]"
    local intel_nova28="Intel(R) Xeon(R) CPU E5-2680 v4 @ 2.40GHz [${sockets}x Sockets, ${cores} Cores/Socket]"
    local amd_easley="AMD EPYC 7662 [${sockets}x Sockets, ${cores}/Socket]"
    local type="${intel_easley}"

    [[ "${partition}" =~ "_bg2" ]] && type="${intel_easley}"
    [[ "${partition}" =~ "_bg4" ]] && type="${intel_easley}"
    [[ "${partition}" =~ "_amd" ]] && type="${amd_easley}"
    [[ "${partition}" =~ "_gpu2" ]] && type="${intel_easley} ${gpu_easley}"
    [[ "${partition}" =~ "_gpu4" ]] && type="${intel_easley} ${gpu_easley}"
    [[ "${partition}" =~ "_20" ]] && type="${intel_nova20}"
    [[ "${partition}" =~ "_28" ]] && type="${intel_nova20}"
    [[ "${partition}" =~ "nova_gpu" ]] && type="${intel_nova20} ${gpu_nova}"

    echo ${type}; return 0

}