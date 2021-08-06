# shellcheck shell=bash

do-plumbing-clone() {
	local uri="$1"
	local id="$2"
	local ref="$3"
	local branch="$4"

	ensure.non_zero 'uri' "$uri"
	ensure.non_zero 'id' "$id"

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

	printf '  -> %s\n' "Cloning Git repository"
	local git_output=
	if ! git_output="$(git clone "${git_args[@]}" 2>&1)"; then
		log.error "Could not clone repository"
		printf "  -> %s\n" "Git output:"
		printf "    -> %s\n" "${git_output%.}"
		exit 1
	fi

	if [ -n "${BPM_IS_TEST+x}" ]; then
		printf "%s\n" "$git_output"
	fi

	# If we are going to a specific revision, do it now
	if [ -n "$ref" ]; then
		local git_output=
		if git_output="$(git -C "$BPM_PACKAGES_PATH/$id" reset --hard "$ref" 2>&1)"; then
			printf "%s\n" "  -> Reseting to revision '$ref'"
		else
			log.error "Could not reset to particular revision '$ref'"
			printf "  -> %s\n" "Is '$ref' actually in '$id'?"
			printf "  -> %s\n" "Git output:"
			printf "    -> %s\n" "${git_output%.}"
			exit 1
		fi

		if [ -n "${BPM_IS_TEST+x}" ]; then
			printf "%s\n" "$git_output"
		fi
	fi
}
