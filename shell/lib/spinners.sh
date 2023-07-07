#!/bin/bash
#  The Auburn HPC Admins
#  Bash Library | spinners.sh | 04.12.22
#  ---------------------------------------------------------
#  A few progress indicator styles for killing time
#  during lengthy operations.
#  Modified from https://unix.stackexchange.com/a/565551
#
#  To use in a separate script ...
#  auhpc-source spinners # or # source /path/to/spinners.sh
#  spinner <style_index> <command_with_args>  


source colors.sh || return 1

function spin_stop() { tput cnorm; }; trap spin_stop EXIT
function cursorBack() { echo -en "\033[$1D"; }
function spin_init() { LC_CTYPE=C; i=0; pid=$!; tput civis; }
function spin_dot() { spin='⠁⠂⠄⡀⢀⠠⠐⠈'; charwidth=3; }
function spin_default() { spin='-\|/'; charwidth=1; }
function spin_hill() { spin="▁▂▃▄▅▆▇█▇▆▅▄▃▂▁"; charwidth=3; }
function spin_rack() { spin="▉▊▋▌▍▎▏▎▍▌▋▊▉"; charwidth=3; }
function spin_arrow() { spin='←↖↑↗→↘↓↙' charwidth=3; }
function spin_block() { spin='▖▘▝▗'; charwidth=3; }
function spin_pie() { spin='◴◷◶◵'; charwidth=3; }
function spin_wheel() { spin='◐◓◑◒'; charwidth=3; }
function spin_disco() { spin='⣾⣽⣻⢿⡿⣟⣯⣷'; charwidth=3; }
function spin_stop() { tput cnorm; }; trap spin_stop EXIT

function spinner() {
  trap "kill ${1} &>/dev/null; exit 1" INT
  spin='-\|/'; LC_CTYPE=C; i=0; pid=${1}
  # kill -0 checks for the existence of a pid
  tput civis; while (kill -0 ${pid} &>/dev/null); do
    i=$(((i+1)%${#spin}))
    printf "%s\033[1D" "${spin:${i}:1}" 2>/dev/null; sleep .1
  done; tput cnorm; wait ${pid}; return ${?}
}

function spin-deluxe-rule() {
  spin='-\|/'; echo -e "\r"; ch=1;for i in {250..232} {232..250} {250..232}; do 
    printf "\033[1;37m${spin:$(( ch % 4 )):1}"; sleep .01; 
    echo -en "\b\033[38;5;${i}m*"; ch=$((ch+1))
  done; printf "\e[0m"
}

spin-type() { 
  tput setaf 2 &>/dev/null
  for ((i=0; i<=${#1}; i++)); do
      printf "%s" "${1:$i:1}"
      local time=$(( ${RANDOM} % 3 ))
      local pause=$(printf "0.%.2d" ${time})
      sleep ${pause}; done
  tput sgr0 2 &>/dev/null
}

# the command to execute is parsed from the second index
# e.g. anything passed after ${1} (the <style_index>)
#
# ("${@:2}") &
# pass the process id of the most recent command (above) to the spinner, 
# which will animate the progress indicator until the pid exits ...

#spinner $! $1 "${@:2}" 

# replaced spinner method <morgaia@auburn.edu> 05.08.23
# function spinner() {
#   pid=$1 
#   LC_CTYPE=C
#   i=0
#   tput civis # cursor invisible
#   case $2 in
#     0)spin_default;;
#     1)spin_dot;;
#     2)spin_hill;;
#     3)spin_rack;;
#     4)spin_arrow;;
#     5)spin_block;;
#     6)spin_pie;;
#     7)spin_wheel;;
#     8)spin_disco;;
#     *)spin_default;;
#   esac
#   while kill -0 $pid 2>/dev/null; do
#     i=$(((i + $charwidth) % ${#spin}))
#     printf "%s" "${spin:$i:$charwidth}"
#     cursorBack 1
#     sleep .1
#   done  
#   wait $pid # capture exit code
#   return $?
# }

