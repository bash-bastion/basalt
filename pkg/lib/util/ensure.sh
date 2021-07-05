# shellcheck shell=bash

# @file ensure.sh
# @brief Ensure particular behavior at runtime

ensure.cd() {
	local dir="$1"
	ensure.nonZero 'dir' "$dir"

	if ! cd "$1"; then
		die "Could not cd to directory '$1'"
	fi
}

ensure.nonZero() {
	local varName="$1"
	local varValue="$2"

	if [ -z "$varName" ] || [ $# -ne 2 ]; then
		die "Internal: Incorrect arguments passed to 'ensure.nonZero'"
	fi

	if [ -z "$varValue" ]; then
		die "Variable '$varName' must be non-zero. Please check the validity of your passed arguments"
	fi
}
