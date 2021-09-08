# shellcheck shell=bash

# @file ensure.sh
# @brief Ensure particular behavior at runtime

ensure.cd() {
	local dir="$1"
	ensure.non_zero 'dir' "$dir"

	if ! cd "$1"; then
		die "Could not cd to directory '$1'"
	fi
}

ensure.non_zero() {
	local varName="$1"
	local varValue="$2"

	if [ -z "$varName" ] || [ $# -ne 2 ]; then
		die "Internal: Incorrect arguments passed to 'ensure.non_zero'"
	fi

	if [ -z "$varValue" ]; then
		die "Variable '$varName' must be non-zero. Please check the validity of your passed arguments"
	fi
}

# @description This is a check to determine if a package actually exists.
# If it does not, then the program fails. This was created to increase
# the integrity of the testing suite. Most of the callsites of this
# function are in 'do-plumbing-link' since we expect a package to exist
# before performing operations on it. This contrasts 'do-plumbing-unlink' -
# in which the behavior is not expected
# @arg $1 package
ensure.package_exists() {
	local id="$1"

	if [ ! -d "$BASALT_PACKAGES_PATH/$id" ]; then
		log.error "Package '$id' does not exist"
		printf "  -> %s" "'$BASALT_PACKAGES_PATH/$id'"
		exit 1
	fi
}

ensure.not_absolute_path() {
	local path="$1"

	if [ "${path::1}" = / ]; then
		die "Path '$path' is not absolute"
	fi
}
