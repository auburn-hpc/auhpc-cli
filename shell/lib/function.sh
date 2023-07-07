#!/bin/bash
#
#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  function.sh | 05.08.23
#  ---------------------------------------------------------

auhpc-tools() {
    local out=( $(grep -Eo "[^function].*[a-z]*[-]?[a-z]{1,3}.*\(\)\ \{" ${AUHPC_LIBPATH}/*.sh | grep -Ev "#.*$" | sed 's/() {$//g' | tr -s '\n' | awk -F':' '{printf "%s\n", $2}' | grep "auhpc" | tr '\n' ' ') )
    printf "%s\n" ${out[@]}
}

function auhpc-function-validate() {
    (( ${#} != 1 )) || [[ -z ${1} ]] && return 1
    local name="${1}"
    local functions=( $(auhpc-tools) )
    local function=$(echo "${functions[@]:0}" | grep -o "${name}") 
    if (( ${?} != 0 )) || [[ -z $function ]]; then
        printf "unknown function '%s'. To show available commands, use ${GRN}auhpc-tools${OFF}\n" ${name} >&2
        return 1;
    fi
    return 0
}

# first argument is a comma delimited string describing a function's definition
# ex "arg1,arg2,=,2" says there are 2 required fields named arg1 and arg2, with no optional fields
# ex "arg1,arg2,<,3" says there are 2 required fields named arg1 and arg2, with one (1) optional fields
# ex "arg1,arg2,>,2" says there are 2 required fields named arg1 and arg2, with an arbitrary number of optional fields
# fields 0-(n-2): names of the required fields to use in the usage output
# field n-1: equality operator, used to determine if the number of provied fields should be greater than, less, than or equal to ...
# field n: required fields,  second char is the calling function's number of required fields 

# example: auhpc-function-init "field1,field2,=,2" ${@}

auhpc-function-init() {
    local adata="${1}"; local ops=${adata#*,*,}; local op=${ops%,*} local val=${ops#*,}
    local aout="${adata/${ops}/}"; # echo -e "adata:${adata}\nops:${ops}\nop:${op}\nval:${val}\naout:${aout}"
    [[ "${op}" =~ (<|>|=) ]] && [[ "${val}" =~ [0-9] ]] || return 1
    auhpc-validate-environment && auhpc-source utility || return 1
    local name="${FUNCNAME[1]}"; local data=( "${@:1:${val}}" )
    local args=( ${data[@]:${val}} ) #echo "args: ${args[@]}" >&2
    local reqs=( ${data[@]:${#args[@]}} ) #echo "reqs (${#reqs[@]}): ${reqs[@]}" >&2
    #local aout=( ${reqs[@]:${reqs[-1]}} ); 
    #echo "auhpc-function-validate-arguments ${#args[@]} ${op} ${val}" >&2
    auhpc-function-validate-arguments ${#data[@]} "${op}" ${val} && return 0 || { \
        echo -e "usage: ${name} $(printf "<%s> " ${aout[@]//,/ })"; return 1; }
}

auhpc-function-clear-metadata() {
    auhpc-function-init ${@} ${#} ">" 0 || return 1; local IFS=$'\n';
    local filter="${2}"; [[ -z ${filter} ]] && filter="."
    local data=( $(sed -n "/^begin=/,/^end=/p" metadata.yml | grep -v "begin\|end" | grep ${filter}) ) 
    for kv in ${data[@]}; do
      local reset=$(echo ${kv} | cut -d'=' -f1 2>&1)
      unset ${reset}
    done; return 0
}

auhpc-function-metadata() {
    (( ${#} == 0 )) && return 1; local IFS=$'\n';
    auhpc-function-clear-metadata "${1}"
    local filter="${2}"; [[ -z ${filter} ]] && filter="."
    local data=( $(sed -n "/^begin=${1}/,/^end=${1}/p" metadata.yml | grep -v "begin\|end" | grep -E "${filter}=") ) 
    for kv in ${data[@]}; do
      eval "${kv}" &>/dev/null || \
      printf "${ORANGE}warning${OFF}: function %s invalid property \"${SKY}%s${OFF}\"" ${1} ${kv} >&2
    #   if [[ "${filter}" != "." ]]; then 
    #     local value=$(echo "${kv}" | cut -d'=' -f2 | tr -d '"(){}' | sed 's/^ //g') 
    #     printf "%s\n" "${value}"
    #   fi
    done; return 0
}

auhpc-function-short() {
    (( ${#} != 1 )) && return 1
    auhpc-function-metadata "${1}" short || return 1
    [[ -z ${short} ]]; return 1
    printf "${LIGHTGRAY}%s${OFF}\n\n" "${short}"
    return 0;
}

auhpc-function-long() {
    (( ${#} != 1 )) && return 1
    auhpc-function-metadata "${1}" long || return 1
    [[ -z ${long} ]]; return 1
    printf "${BLK}%b${OFF}\n\n" "${long}"
    return 0;
}

auhpc-function-header() {
    (( ${#} != 1 )) && return 1
    auhpc-function-metadata "${1}" || return 1
    local source=$(auhpc-function-source "${1}")
    printf "\n${GRY}${AUHPC_SETNAME} :: %s :: ${GRN}%b${GRY}()${OFF}\n\n" "$(basename ${source})" "${1}"
    return 0;
}


auhpc-function-source() {
    (( ${#} != 1 )) && return 1
    local out=$(grep -m1 -Eo "[^function].*${1}.*\(\)\ \{" ${AUHPC_LIBPATH}/*.sh | grep -Ev "#.*$" | sed 's/() {$//g' | tr -s '\n' | awk -F':' '{printf "%s\n", $1}')
    [[ ! -f "${out}" ]] && return 1
    printf "%s\n" ${out}
}

auhpc-function-syntax() {
    [[ ! -z ${1} ]] && auhpc-function-validate "${1}" && local function="${1}" || return 1
    auhpc-function-metadata "${1}"  || return 1
    local syntax="${GRN}${function}${OFF} "
    local l='['; local r=']'
    for i in $(seq 0 $((${#args[@]}-1))); do
        local opt=${opts[${i}]}; (( ${opt} == 1 )) && l='<' && local r='>'
        syntax+="${GRY}${l}${CYAN}${args[${i}]}${GRY}${r}${OFF} "
    done
    printf "usage: %b\n\n" "${syntax}"
}

auhpc-function-example() {
    [[ ! -z ${1} ]] && auhpc-function-validate "${1}" && local function="${1}" || return 1
    auhpc-function-metadata "${1}"  || return 1
    (( ${#tests[@]} == 0 )) && return 1
    local syntax="${GRN}${function}${OFF} "; local l=""; local r=""
    for i in $(seq 0 $((${#args[@]}-1))); do
        [[ "${tests[${i}]}" =~ " " ]] && l="\"" && r="\""
        syntax+="${GRY}${CYAN}${l}${tests[${i}]}${r}${GRY}${OFF} "
    done
    printf "example: %b\n" "${syntax}"
}

auhpc-function-test() {
    
    [[ ! -z ${1} ]] && auhpc-function-validate "${1}" && local function="${1}" || return 1
    
    auhpc-function-example "${1}" || return 1; (( ${#tests[@]} == 0 )) && return 1

    confirm "run example" || return 0
    
    local syntax="${function} "
    for i in $(seq 0 $((${#args[@]}-1))); do
        [[ "${tests[${i}]}" =~ " " ]] && l="\"" && r="\""
        syntax+="${l}${tests[${i}]}${r} "
    done

    local source=$(auhpc-function-source ${function}) || return 1
    source "${source}" &>/dev/null || return 1

    local result=$( ${syntax} ); local code=${?}; local msg=""
    
    [[ -z ${result} ]] || [[ "${result}" == "" ]] && (( ${#fields[@]} > 0 )) && msg+="expected output, but got nothing\n"
    [[ -z ${fields} ]] || (( ${#fields[@]} == 0 )) && local msg+="returned code: ${code}" || local msg+="${result}\nreturned code: ${code}"
    
    printf "%b\n" "${msg}"

}

auhpc-function-display() {
    [[ ! -z ${1} ]] && auhpc-function-validate "${1}" && local function="${1}" || return 1
    #auhpc-function-metadata "${function}"
    auhpc-function-header "${function}"
    auhpc-function-short "${function}"
    auhpc-function-syntax "${function}"
    auhpc-function-long "${function}"
}

auhpc-help() {
    local function="${1}"
    if [[ -z ${1} ]]; then
       printf "\n${SKY}%s${OFF} :: General Help\n" ${AUHPC_SETNAME}
       printf "To show available commands, use ${GRN}auhpc-tools${OFF}\n"
       printf "For a specific command, use ${GRN}auhpc-help-tools${OFF} <${PUR}command_name${OFF}>\n"
       cat ${AUHPC_LIBPATH}/README.md
       return 0;
    fi
    auhpc-function-validate "${function}"
    auhpc-function-display "${function}"
    auhpc-function-test "${function}"
} >&2

auhpc-function-help() {

        local cmd="${1}"; [[ -z ${cmd} ]] && auhpc-function-validate ${cmd} || return 1
        local data=( $(sed -n "/^begin=${function}/,/^end=${function}/p" metadata.yml | grep -v "begin\|end") )
        #IFS=$'\n'; local data=( $(IFS=$'\n'; grep -E "^${function}:" ${AUHPC_LIBPATH}/metadata.yml | tr ':' '\n' | tr -d '"') )
        local source=$(auhpc-function-source ${cmd})
        local offset=${data[2]};
        local args=( ${data[@]:3:$((3+${offset}))} )

        printf "\n${GRY}${AUHPC_SETNAME} :: %s :: ${GRN}%b${GRY}()${OFF}\n" "$(basename ${source})" "${cmd}"
        printf "\n${LIGHTGRAY}%s${OFF}\n\n" "${data[5]}" 
        #printf "%s${OFF}\n\n" ${data[7]}
        printf "syntax: ${GRN}${cmd}${OFF} ${GRY}<${CYAN}%s${GRY}>${OFF}\n" ${data[3]}
        printf "example: ${GRN}${cmd}${OFF} ${GRY}\"${CYAN}%s${GRY}\"${OFF}\n\n" "${data[9]}"
        read -p "run example (y/N)? " run; [[ "${run}" =~ ^(y|Y|yes|Yes|YES) ]] || return 0
        source "${source}" &>/dev/null
        confirm "${data[9]}"
        printf "returned: %d (\${?})\n\n" ${?}

}
