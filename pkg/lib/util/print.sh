# shellcheck shell=bash

# @file print.sh
# @brief Prints statements that have proper indentation

print.die() {
	print.error 'Error' "$1"
	exit 1
}

print.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2"
	else
		printf "\033[0;31m%11s\033[0m %s\n" "$1" "$2"
	fi
}

print.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2"
	else
		printf "\033[0;33m%11s\033[0m %s\n" "$1" "$2"
	fi
}

print.info() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2"
	else
		printf "\033[0;32m%11s\033[0m %s\n" "$1" "$2"
	fi
}

print.debug() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2"
	else
		printf "\033[0;32m%11s\033[0m %s\n" "$1" "$2"
	fi
}
