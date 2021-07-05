# shellcheck shell=bash

# @summary: Globally installs package runtime dependencies.
# It installs the package dependencies, specified with the
# DEPS= variable on package.sh.
# Usage: basher _deps <package>
# Example: DEPS=username/repo1:otheruser/repo2

basher-plumbing-deps() {
	if [ "$#" -ne 1 ]; then
		die "Wrong arguments to basher-plumbing-deps"
	fi

	local package="$1"

	if [ ! -e "$NEOBASHER_PACKAGES_PATH/$package/package.sh" ]; then
		exit
	fi

	source "$NEOBASHER_PACKAGES_PATH/$package/package.sh"
	IFS=: read -ra deps <<< "$DEPS"

	for dep in "${deps[@]}"; do
		basher-install "$dep"
	done
}
