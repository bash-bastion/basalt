# shellcheck shell=bash

# @file ensure.sh
# @brief Ensure particular behavior at runtime

ensure.cd() {
	local dir="$1"

	if ! cd "$dir"; then
		print.die "Could not cd to directory '$dir'"
	fi
}

ensure.not_absolute_path() {
	local path="$1"

	if [ "${path::1}" = / ]; then
		print.die "Path '$path' is not absolute"
	fi
}
