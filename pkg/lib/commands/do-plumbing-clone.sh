# shellcheck shell=bash

do-plumbing-clone() {
	local uri="$1"
	local package="$2"
	local ref="$3"

	ensure.non_zero 'uri' "$uri"

	if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi

	local -a git_args=(--recursive)

	if [ -z "${BPM_FULL_CLONE+x}" ]; then
		git_args+=(--depth=1)
	fi

	if [ -n "$ref" ]; then
		git_args+=(--branch "$ref")
	fi

	git_args+=("$uri")
	git_args+=("$BPM_PACKAGES_PATH/$package")

	log.info "Cloning package '$package'"
	git clone "${git_args[@]}"
}
