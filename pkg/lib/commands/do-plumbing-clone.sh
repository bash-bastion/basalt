# shellcheck shell=bash

do-plumbing-clone() {
	local uri="$1"
	local package="$2"
	local ref="$3"

	ensure.nonZero 'uri' "$uri"

	if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi

	local -a gitArgs=(--recursive)

	if [ -z "${BPM_FULL_CLONE+x}" ]; then
		gitArgs+=(--depth=1)
	fi

	if [ -n "$ref" ]; then
		gitArgs+=(--branch "$ref")
	fi

	gitArgs+=("$uri")
	gitArgs+=("$BPM_PACKAGES_PATH/$package")

	log.info "Cloning package '$package'"
	git clone "${gitArgs[@]}"
}
