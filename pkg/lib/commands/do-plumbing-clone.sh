# shellcheck shell=bash

do-plumbing-clone() {
	local use_ssh="$1"
	local site="$2"
	local package="$3"
	local ref="$5"

	ensure.nonZero 'use_ssh' "$use_ssh"
	ensure.nonZero 'site' "$site"
	ensure.nonZero 'package' "$package"

	if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
		log.error "Package '$package' is already present"
		exit
	fi

	local -a gitArgs=(--recursive)

	if [ -z "${BPM_FULL_CLONE+x}" ]; then
		gitArgs+=(--depth=1)
	fi

	if [ -n "$ref" ]; then
		gitArgs+=(-b "$ref")
	fi

	if [ "$use_ssh" = "true" ]; then
		gitArgs+=("git@$site:$package.git")
	else
		gitArgs+=("https://$site/$package.git")
	fi

	gitArgs+=("$BPM_PACKAGES_PATH/$package")

	git clone "${gitArgs[@]}"
}
