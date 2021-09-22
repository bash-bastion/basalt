# shellcheck shell=bash

# @file print_flat.sh
# @brief Prints statements that are not indented

print.die() {
	print.error "$@"
	exit 1
}

print.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Error: %s\n" "$1"
	else
		printf "\033[0;31mError\033[0m %s\n" "$1" >&2
	fi
}

print.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Warn: %s\n" "$1"
	else
		printf "\033[0;33mWarn\033[0m %s\n" "$1" >&2
	fi
}

print.info() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Info: %s\n" "$1"
	else
		printf "\033[0;32mInfo\033[0m %s\n" "$1" >&2
	fi
}
