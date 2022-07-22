# shellcheck shell=bash

# @file print.sh
# @brief Prints statements that are not indented

print.die() {
	print.error "$1"
	exit 1
}

# @description Print a _fatal_ error. Use this for internal error (like asserts)
print.fatal() {
	if std.should_print_color_stderr; then
		printf "\033[0;35m%11s:\033[0m %s\n" 'Fatal' "$1" >&2
	else
		printf "%11s: %s\n" "Fatal" "$1" >&2
	fi

	core.print_stacktrace
	exit 1
}

print.error() {
	if std.should_print_color_stderr; then
		printf "\033[0;31m%11s:\033[0m %s\n" 'Error' "$1" >&2
	else
			printf "%11s: %s\n" "Error" "$1" >&2
	fi
}

print.warn() {
	if std.should_print_color_stderr; then
		printf "\033[0;33m%11s:\033[0m %s\n" 'Warning' "$1" >&2
	else
		printf "%11s: %s\n" 'Warning' "$1" >&2
	fi
}

print.info() {
	if std.should_print_color_stdout; then
		printf "\033[0;32m%11s:\033[0m %s\n" 'Info' "$1"
	else
		printf "%11s: %s\n" 'Info' "$1"
	fi
}

print.green() {
	if std.should_print_color_stdout; then
		printf "\033[0;32m%11s:\033[0m %s\n" "$1" "$2"
	else
		printf "%11s: %s\n" "$1" "$2"
	fi
}
