#!/bin/bash -e

export DKH_REPO=${DKH_REPO:-"reach3"}
export TAG=${TAG:-"latest"}

# terminal colors
FG_GREEN_BOLD="$(tput setaf 2)$(tput bold)"
FG_GREY="$(tput sgr0)"
FG_RED_BOLD="$(tput setaf 1)$(tput bold)"
FG_BOLD="$(tput bold)"
DEFAULT="$(tput sgr0)"

YEAR="$(date +'%Y')"
FQDN=$(hostname -f)
PUBLIC_IP="$(curl -4 -s ifconfig.co)"
VERSION="20.04"

###############################################################################
# Functions
###############################################################################

# Restore cursor position and clear rest of the screen
restore_cursor()
{
	tput rc && tput ed
}

# Save cursor position
save_cursor()
{
	tput sc
}

# Move cursor up n lines and clear rest of the screen
move_up_and_clear()
{
	local n=1
	while (( $n <= $1 ))
	do
		tput cuu1
		n=$(( n+1 ))
	done
	tput ed
}

print_header()
{
	printf "_______________________________________________________________\n" && printf "${FG_GREEN_BOLD}"
	printf "                                                               \n"
	printf "  Ezuce | Reachme                                              \n"
	printf "                                                               \n" && printf "${DEFAULT}"
	printf "  Contact Center Solution                                      \n"
	printf "_______________________________________________________________\n" && printf "${DEFAULT}${FG_GREY}"
	printf " Version: ${VERSION}                  Copyright(C) ${YEAR} eZuce, Inc.\n"
	printf "\n\n${DEFAULT}"
}

print_missing_dependency()
{
	printf "\n${FG_RED_BOLD} Important Dependency Missing${DEFAULT}\n\n"
	printf "\t${FG_BOLD}$1${DEFAULT}: not found\n"
	printf "\n${FG_GREY} Please, execute following commands as root, then run installation again:${DEFAULT}\n"
	printf "${FG_BOLD}\n"
	printf "  curl https://raw.githubusercontent.com/ezuce/reach-install/master/reach-host-setup.sh > reach-host-setup.sh\n"
	printf "  chmod +x host-setup.sh\n"
	printf "  ./host-setup.sh\n"
	printf "${DEFAULT}\n\n"
}

query_for_fqdn()
{
	cat <<-EOF
	Enter Reachme ${FG_BOLD}Fully Qualified Domain Name${DEFAULT} or press <Enter>
	if autodetected value ${FG_GREEN_BOLD}[${FQDN}]${DEFAULT} is correct
EOF
	read -p "> " DOMAIN
	DOMAIN=${DOMAIN:-${FQDN}}
}

query_for_ext_ip()
{
	cat <<-EOF
	Enter Reachme ${FG_BOLD}Public IP Address${DEFAULT} or press <Enter>
	if autodetected value ${FG_GREEN_BOLD}[${PUBLIC_IP}]${DEFAULT} is correct
EOF
}

query_for_https_option()
{
	cat <<-EOF
	${FG_BOLD}HTTPS configuration${DEFAULT}, please select one of the options below:

	    1. unencrypted HTTP ${FG_GREEN_BOLD}[default]${DEFAULT}
	    2. HTTPS with Let's Encrypt certificate
	    3. HTTPS with my own certificate

EOF

	while true; do
		read -p "Enter selection [1-3] > " HTTPS

		# Act on selection
		case ${HTTPS} in
			1|"")
				HTTPS_OPTION_STRING="unencrypted HTTP"
				HTTPS_OPTION="1"
				break 2
				;;
			2)
				HTTPS_OPTION_STRING="HTTPS with Let's Encrypt certificate"
				HTTPS_OPTION="2"
				printf "\nEnter ${FG_BOLD}Let's Encrypt email${DEFAULT}:\n"
				read -p "> " LE_EMAIL
				break 2
				;;
			3)
				HTTPS_OPTION_STRING="HTTPS with my own certificate"
				HTTPS_OPTION="3"
				CERT_NAME=$(echo ${DOMAIN} | sed 's/\./_/g')
				break 2
				;;
			*)
				printf "Invalid entry ... press any key to continue."
				;;
		esac
		read -n 1
		move_up_and_clear 2
	done
}

parse_cli_arguments()
{
	while [[ "$#" -gt 0 ]]; do
	case "$1" in
		-f|--force)
			FORCE_INSTALL=1
			;;
		-h|--help)
			print_help
			exit 1
			;;
		--arg_1=*)
			arg_1="${1#*=}"
			;;
		*)
			printf "${FG_RED_BOLD}Error:${DEFAULT} Invalid command line argument ${FG_BOLD}$1${DEFAULT}\n\n\n"
			print_help
			exit 1
	esac
	shift
	done
}

print_help()
{
	printf "Options:\n"
	printf "\t-h, --help\tprints this help information\n"
	printf "\t-f, --force\tforce reinstall\n"
	printf "\n\n"
}

###############################################################################
# Main script logic
###############################################################################

clear && printf '\e[3J'

print_header
save_cursor

parse_cli_arguments $@

# load env variables stored in .env file
if test -e ./.env; then
	source ./.env
fi

# check if we have docker installed
if ! which docker > /dev/null 2>&1; then
{
	print_missing_dependency docker
	exit 1
}
fi

# check if we have docker-compose installed
if ! which docker-compose > /dev/null 2>&1; then
{
	print_missing_dependency docker-compose
	exit 1
}
fi

# check if we have FQDN set, if not query for it
if test -z "${DOMAIN}" || test "${FORCE_INSTALL}" = 1; then
	query_for_fqdn
fi

# print settings confirmed at this point
restore_cursor
printf "${FG_BOLD} Your settings:${DEFAULT}\n\n"
printf "\tDomain: ${FG_GREEN_BOLD}${DOMAIN}${DEFAULT}\n"
save_cursor
printf "_______________________________________________________________\n\n"

# check if we have external IP set, if not query for it
if test -z "${EXT_IP}" || test "${FORCE_INSTALL}" = 1; then
	query_for_ext_ip
	read -p "> " EXT_IP
	EXT_IP=${EXT_IP:-${PUBLIC_IP}}
fi

# print settings confirmed at this point
restore_cursor
printf "\tPublic IP: ${FG_GREEN_BOLD}${EXT_IP}${DEFAULT}\n"
save_cursor
printf "_______________________________________________________________\n\n"

# check if we have HTTPS option set, if not query for it
if test -z "${HTTPS_OPTION}" || test "${FORCE_INSTALL}" = 1; then
	query_for_https_option
fi

# print settings confirmed at this point
restore_cursor
printf "\tHTTPS: ${FG_GREEN_BOLD}${HTTPS_OPTION_STRING}${DEFAULT}\n"
if [[ ! -z ${LE_EMAIL} ]]
then
	printf "\tLet's Encrypt email: ${FG_GREEN_BOLD}${LE_EMAIL}${DEFAULT}\n"
fi
save_cursor
printf "_______________________________________________________________\n\n"

# create/renew .env file
cat <<-EOF >.env
	COMPOSE_PROJECT_NAME=reach

	PROJECT_BRANCH=
	CONTAINER_NAME_PREFIX=
	NETWORK_NAME_SUFFIX=

	DOMAIN=${DOMAIN}
	EXT_IP=${EXT_IP}
	HTTPS_OPTION=${HTTPS_OPTION}
	HTTPS_OPTION_STRING="${HTTPS_OPTION_STRING}"
	LE_EMAIL=${LE_EMAIL}
	CERT_NAME=${CERT_NAME}
EOF

# move to actual installation ...
printf "${FG_BOLD}Going to pull and start Reachme services ...${DEFAULT}\n\n"

# start app with docker-compose
docker-compose pull && docker-compose up --no-build -d

# ... all done
printf "\n${FG_BOLD}... done${DEFAULT}\n\n"

