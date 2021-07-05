# shellcheck shell=bash

# @summary Clones a package from a site, but doesn't install it
# Usage: basher _clone <use_ssh> <site> <package> [<ref>]

basher-plumbing-clone() {
	local useSsh="$1"
	local site="$2"
	local package="$3"
	local ref="$4"

	ensure.nonZero 'useSsh' "$useSsh"
	ensure.nonZero 'site' "$site"
	ensure.nonZero 'package' "$package"

	IFS=/ read -r user name <<< "$package"

	if [ -z "$user" ]; then
		die "Wrong arguments to basher-plumbing-clone 4"
	fi

	if [ -z "$name" ]; then
		die "Wrong arguments to basher-plumbing-clone 5"
	fi

	if [ -e "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		log.info "Package '$package' is already present"
		exit
	fi

	local -a gitArgs=()

	if [ "$BASHER_FULL_CLONE" != "true" ]; then
		gitArgs+=(--depth=1)
	fi

	if [ -n "$ref" ]; then
		gitArgs+=(-b "$ref")
	fi

	gitArgs+=(--recursive)

	if [ "$useSsh" = "true" ]; then
		gitArgs+=("git@$site:$package.git")
	else
		gitArgs+=("https://$site/$package.git")
	fi

	gitArgs+=("$NEOBASHER_PACKAGES_PATH/$package")

	git clone "${gitArgs[@]}"
}
