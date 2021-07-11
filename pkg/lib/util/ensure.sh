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
# that is not an expectation
# @arg $1 package
ensure.package_exists() {
	local package="$1"

	if [ ! -d "$BPM_PACKAGES_PATH/$package" ]; then
		die "Package '$package' does not exist"
	fi
}

ensure.git_repository() {
	local dir="$1"
	local id="$2"

	if [ ! -d "$dir/.git" ]; then
		die "Package '$id' is not a Git repository. Unlink or otherwise remove it at '$dir'"
	fi
}
