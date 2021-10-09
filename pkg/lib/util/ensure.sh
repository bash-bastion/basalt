# shellcheck shell=bash

# @file ensure.sh
# @brief Ensure particular behavior at runtime

ensure.cd() {
	local dir="$1"

	ensure.nonzero 'dir'

	if ! cd "$dir"; then
		bprint.fatal "Could not cd to directory '$dir'"
	fi
}

ensure.not_absolute_path() {
	local path="$1"

	ensure.nonzero 'path'

	if [ "${path::1}" = / ]; then
		bprint.die "Path '$path' is not absolute"
	fi
}
# @description Ensure that a variable name is non-zero
ensure.nonzero() {
	local name="$1"

	if [ -z "$name" ]; then
		bprint.fatal "Argument 'name' for function 'ensure.nonzero' is empty"
	fi

	local -n value="$name"
	if [ -z "$value" ]; then
		bprint.fatal "Argument '$name' for function '${FUNCNAME[1]} ${FUNCNAME[2]} ${FUNCNAME[3]}' is empty"
	fi
}

ensure.dir() {
	local dir="$1"

	ensure.nonzero 'dir'

	if [ ! -d "$dir" ]; then
		bprint.fatal "A directory at '$dir' was expected to exist"
	fi
}
