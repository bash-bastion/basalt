# shellcheck shell=bash

# @file print_flat.sh
# @brief Prints statements that are not indented

print.die() {
	print.error "$1"
	if (($# > 1)); then
		print.auxiliary "${@:2}"
	fi
	exit 1
}

print.internal_die() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Internal Error: %s\n" "$1"
	else
		printf "\033[0;31mInternal Error\033[0m %s\n" "$1" >&2
	fi
	if (($# > 1)); then
		print.auxiliary "${@:2}"
	fi
	exit 1
}

# TODO: is this needed?
print.auxiliary() {
	printf '      -> %s\n' "$@"
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
