# shellcheck shell=bash

# @file print_flat.sh
# @brief Prints statements that are not indented

# Non-indent
print.die() {
	print.error "$1"
	exit 1
}

print.internal_die() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Internal Error: %s\n" "$1" >&2
	else
		printf "\033[0;31mInternal Error\033[0m %s\n" "$1" >&2
	fi

	exit 1
}

print.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Error: %s\n" "$1" >&2
	else
		printf "\033[0;31mError\033[0m %s\n" "$1" >&2
	fi
}

print.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Warn: %s\n" "$1" >&2
	else
		printf "\033[0;33mWarn\033[0m %s\n" "$1" >&2
	fi
}

print.info() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "Info: %s\n" "$1"
	else
		printf "\033[0;32mInfo\033[0m %s\n" "$1"
	fi
}

# Indent
print.indent-die() {
	print.indent-red 'Error' "$1"
	exit 1
}

print.indent-red() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2" >&2
	else
		printf "\033[0;31m%11s\033[0m %s\n" "$1" "$2" >&2
	fi
}

print.indent-yellow() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2" >&2
	else
		printf "\033[0;33m%11s\033[0m %s\n" "$1" "$2" >&2
	fi
}

print.indent-green() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "$1" "$2"
	else
		printf "\033[0;32m%11s\033[0m %s\n" "$1" "$2"
	fi
}

newindent.die() {
	newindent.error "$1"
	exit 1
}

newindent.error() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" "Error" "$1"
	else
		printf "\033[0;31m%11s\033[0m %s\n" 'Error' "$1"
	fi
}

newindent.warn() {
	if [ -n "${NO_COLOR+x}" ] || [ "$TERM" = dumb ]; then
		printf "%11s %s\n" 'Warn' "$1" >&2
	else
		printf "\033[0;33m%11s\033[0m %s\n" 'Warn' "$1" >&2
	fi
}
