# shellcheck shell=bash

# @summary Clones a package from a site, but doesn't install it
# Usage: basher _clone <use_ssh> <site> <package> [<ref>]

basher-plumbing-clone() {
	if [[ "$#" -ne 3 && "$#" -ne 4 ]]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	local use_ssh="$1"
	local site="$2"
	local package="$3"
	local ref="$4"

	if [ -z "$use_ssh" ]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	if [ -z "$site" ]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	if [ -z "$package" ]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	if [ -z "$ref" ]; then
		BRANCH_OPTION=""
	else
		BRANCH_OPTION="-b $ref"
	fi

	IFS=/ read -r user name <<< "$package"

	if [ -z "$user" ]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	if [ -z "$name" ]; then
		die "Wrong arguments to basher-plumbing-clone"
	fi

	if [ -e "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		printf "%s" "Package '$package' is already present"
		exit
	fi

	if [ "$BASHER_FULL_CLONE" = "true" ]; then
		DEPTH_OPTION=""
	else
		DEPTH_OPTION="--depth=1"
	fi

	if [ "$use_ssh" = "true" ]; then
		URI="git@$site:$package.git"
	else
		URI="https://$site/$package.git"
	fi

	git clone $DEPTH_OPTION $BRANCH_OPTION --recursive "$URI" "$NEOBASHER_PACKAGES_PATH/$package"
}
