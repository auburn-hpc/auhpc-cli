#  The Auburn HPC Admins
#  Bash Library
#  ---------------------------------------------------------
#  colors.sh | 04.12.22
#  Source this file in your scripts for convenience, so
#  you don't have to remember the escape codes.
#
#  ex. source /path/to/colors.sh
#  echo -e "${RED}Hello ${BLUE}World${YELLOW}!${CLEAR}"
#  
#  See samples.sh and the AUHPC Bash Library README for
#  more detailed information.
#  ---------------------------------------------------------

# style functions

export BOLD='\e[1;'
export BOF='\e[21m;'
function bold() { printf '%b%b' "${BOLD}" "${1#*[}"; }


# normal codes

export CLEAR='\e[0m' # No Color
export BLACK='\e[0;30m'
export GRAY='\e[1;30m'
export LIGHTRED='\e[1;31m'
export GREEN='\e[0;32m'
export LIGHTGREEN='\e[1;32m'
export BROWN='\e[0;33m'
export YELLOW='\e[1;33m'
export BLUE='\e[0;34m'
export LIGHTBLUE='\e[1;34m'
export PURPLE='\e[0;35m'
export LIGHTPURPLE='\e[1;35m'
export CYAN='\e[0;36m'
export LIGHTCYAN='\e[1;36m'
export LIGHTGRAY='\e[0;37m'
export LG='\e[38;5;247m'
export WHITE='\e[1;37m'
export CHARCOAL='\e[38;5;0m'
export MAROON='\e[38;5;1m'

# short codes

export GRN='\e[38;5;2m'
export YEL='\e[38;5;3m'
export BLU='\e[38;5;4m'
export PUR='\e[38;5;5m'
export CYN='\e[38;5;6m'
export WHT='\e[38;5;7m'
export GRY='\e[38;5;8m'
export MAG='\e[38;5;128m'
export LMG='\e[3;49;95m'
export BRD='\e[38;5;9m'
export BGN='\e[38;5;10m'
export BYL='\e[38;5;11m'
export BBL='\e[38;5;12m'
export BPP='\e[38;5;13m'
export BCY='\e[38;5;14m'
export BWT='\e[38;5;15m'
export BLK='\e[38;5;16m'
export ORANGE='\e[38;5;214m'
export DKORG='\e[38;5;208m'
export RED='\e[1;31m'
export SKY='\e[38;5;33m'
export GRY='\e[38;5;8m'
export LGY='\e[38;5;249m'
export DWT='\e[38;5;247m'
export BLK='\e[38;5;0m'
export RED='\e[38;5;1m'
export YEL='\e[38;5;3m'
export GRN='\e[38;5;2m'
export WHT='\e[38;5;7m' 

# log \ status codes
export INFO='\e[38;5;33m'
export WARN='\e[38;5;214m'

# cursor codes
export OFF='\e[0m'
export ERSE='\033[0K'
export DELC='\033[9D'
export DELB='\r'
export DELP='\033[3D'

# special char formats

export DOT="${DWT}*${OFF}"
function ol() { printf "${DWT}${1}${GRY}.${OFF} "; }

