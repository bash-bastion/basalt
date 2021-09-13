# shellcheck shell=bash

print.die() {
	print.error "$@"
	exit 1
}

# @description Print an error message
print.die_early() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Error: %s\n" "$*"
	else
		printf "\033[0;31mError\033[0m %s\n" "$*" >&2
	fi

	exit 1
}

print.error() {
	local red='\033[0;31m'
	local reset='\033[0m'

	printf "$red%11s$reset %s\n" "$@"
}

print.warn() {
	local yellow='\033[0;33m'
	local reset='\033[0m'

	printf "$yellow%11s$reset %s\n" "$@"
}

print.info() {
	local green='\033[0;32m'
	local reset='\033[0m'

	printf "$green%11s$reset %s\n" "$@"
}

print.debug() {
	local blue='\033[0;34m'
	local reset='\033[0m'

	printf "$blue%11s$reset %s\n" "$@"
}
