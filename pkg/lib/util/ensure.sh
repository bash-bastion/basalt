# shellcheck shell=bash

# @file ensure.sh
# @brief Ensure particular behavior at runtime

ensure.cd() {
	local dir="$1"

	if ! cd "$dir"; then
		print.internal_die "Could not cd to directory '$dir'"
	fi
}

ensure.not_absolute_path() {
	local path="$1"

	if [ "${path::1}" = / ]; then
		print.die "Path '$path' is not absolute"
	fi
}
# @description Ensure that a variable name is non-zero
ensure.nonzero() {
	local name="$1"

	if [ -z "$name" ]; then
		print.internal_die "Argument 'name' for function 'ensure.nonzero' is empty"
	fi

	local -n value="$name"
	if [ -z "$value" ]; then
		print.internal_die "Argument '$name' for function '${FUNCNAME[1]}' is empty"
	fi
}

ensure.dir() {
	local dir="$1"

	ensure.nonzero 'dir'

	if [ ! -d "$dir" ]; then
		print.internal_die "A directory at '$dir' was expected to exist"
	fi
}
