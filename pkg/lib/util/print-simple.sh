# shellcheck shell=bash

# @file print_flat.sh
# @brief Prints statements that are not indented

print_simple.die() {
	print_simple.error "$@"
	exit 1
}

print_simple.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Error: %s\n" "$1"
	else
		printf "\033[0;31mError\033[0m %s\n" "$1" >&2
	fi
}

print_simple.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Warn: %s\n" "$1"
	else
		printf "\033[0;33mWarn\033[0m %s\n" "$1" >&2
	fi
}

print_simple.info() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Info: %s\n" "$1"
	else
		printf "\033[0;32mInfo\033[0m %s\n" "$1" >&2
	fi
}
