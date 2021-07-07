# shellcheck shell=bash

# @summary Clones a package from a site, but doesn't install it
# Usage: bpm plumbing-clone <use_ssh> <site> <package> [<ref>]

bpm-plumbing-clone() {
	local useSsh="$1"
	local site="$2"
	local user="$3"
	local repository="$4"
	local ref="$5"

	ensure.nonZero 'useSsh' "$useSsh"
	ensure.nonZero 'site' "$site"
	ensure.nonZero 'user' "$user"
	ensure.nonZero 'repository' "$repository"

	local package="$user/$repository"

	if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
		log.info "Package '$package' is already present"
		exit
	fi

	local -a gitArgs=(--recursive)

	if [ -z "${BPM_FULL_CLONE+x}" ]; then
		gitArgs+=(--depth=1)
	fi

	if [ -n "$ref" ]; then
		gitArgs+=(-b "$ref")
	fi

	if [ "$useSsh" = "true" ]; then
		gitArgs+=("git@$site:$package.git")
	else
		gitArgs+=("https://$site/$package.git")
	fi

	gitArgs+=("$BPM_PACKAGES_PATH/$package")

	git clone "${gitArgs[@]}"
}
