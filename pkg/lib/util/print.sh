# shellcheck shell=bash

# TODO: not 15?
print.error() {
	local red='\033[0;31m'
	local reset='\033[0m'

	printf "$red%15s$reset %s\n" "$@"
}

print.warn() {
	local yellow='\033[0;33m'
	local reset='\033[0m'

	printf "$yellow%15s$reset %s\n" "$@"
}

print.info() {
	local green='\033[0;32m'
	local reset='\033[0m'

	printf "$green%15s$reset %s\n" "$@"
}

print.debug() {
	local blue='\033[0;34m'
	local reset='\033[0m'

	printf "$blue%15s$reset %s\n" "$@"
}
