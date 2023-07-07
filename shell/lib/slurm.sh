#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  slurm.sh | 05.08.23
#  functions for cluster identity, resource state, and
#  job submission
#  ---------------------------------------------------------

[[ ! "$0" = "$BASH_SOURCE" ]] || { printf "\ndirect execution not supported. to use this script:\n\nsource $(readlink -f ${BASH_SOURCE[0]})\n\n" >&2; exit 1; }

source partitions.sh
source nodes.sh
source labs.sh
source output.sh
source function.sh

function auhpc-batch-script() {
    
    local target=( $(auhpc-partition-max-core) ) || return 1
    local experiment="${1}"
    local tag=$(date +'%m%d-%H%M')
    
    [[ -z ${experiment} ]] && experiment="$(auhpc-experiment "run")"
    local paths="$(auhpc-experiment-paths)"

    printf "#!/bin/bash\n\n"
    printf "# -- script generated by %s [%s]\n\n" "${AUHPC_SETNAME}" $(date +'%F')
    printf "#SBATCH --job-name=%s\n" "${experiment}"
    printf "#SBATCH --partition=%s\n" "${target[0]}"
    printf "#SBATCH --nodes=%s\n" "${target[1]}"
    printf "#SBATCH --ntasks=%d\n" "${target[2]}"
    printf "#SBATCH --mail-user=%s\n" "${USER}@auburn.edu"
    printf "#SBATCH --mail-type=%s\n" "ALL" 

}

function auhpc-experiment() {

    (( ${#} == 0 )) && return 1 
    
    local stamp=$(date +'%m%d-%H%M')
    local experiment="${1}"
    local tag="-${2}-"; [[ -z ${2} ]] && tag="-$(( ${RANDOM}%10000+20000 ))-"
    local id="${experiment}${tag}${stamp}"
    
    printf "%s\n" ${id}

}

function auhpc-experiment-paths() {

    local experiment="${1}"; (( ${#} == 0 )) || [[ -z ${experiment} ]] && return 1
    local trunk="${2}"
    
    [[ -z ${trunk} ]] && trunk="${HOME}"
    
    local parts=( "$(echo "${experiment}" | tr -s ' -_' | sed 's/[-_ ]/ /g' | awk '{for(i=1;i<=NF;i++) printf "%s ", $i}')" )
    local path="${trunk}/${parts// //}"; path=${path%/*}

    [[ -e ${path} ]] && { printf "path %s exists. exiting" ${path}; return 1; }

    [[ ! -e ${path} ]] && confirm "create ${path}" && try "mkdir -p ${path}" "creating ${path}"
    
    printf "#SBATCH --output=%s\n" "${path}/${experiment}.out"
    printf "#SBATCH --error=%s\n" "${path}/${experiment}.err"

}
