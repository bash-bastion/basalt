# shellcheck shell=bash

do-plumbing-clone() {
	local uri="$1"
	local id="$2"
	local ref="$3"
	local branch="$4"

	ensure.non_zero 'uri' "$uri"
	ensure.non_zero 'id' "$id"

	# TODO this is invalid in the test suite
	if [ -e "$BPM_PACKAGES_PATH/$id" ]; then
		die "Package '$id' is already present"
	fi

	local -a git_args=(--recursive)

	if [[ -z "${BPM_FULL_CLONE+x}" && -z "$ref" ]]; then
		git_args+=(--depth=1)
	fi

	if [ -n "$branch" ]; then
		git_args+=(--single-branch --branch "$branch")
	fi

	git_args+=("$uri")
	git_args+=("$BPM_PACKAGES_PATH/$id")

	printf '%s\n' "  -> Cloning Git repository"
	local git_output=
	if ! git_output="$(git clone "${git_args[@]}" 2>&1)"; then
		log.error "Could not clone repository"
		printf "%s" "$git_output"
		exit 1
	fi

	if [ -n "${BPM_MODE_TEST+x}" ]; then
		printf "%s" "$git_output"
	fi
}
