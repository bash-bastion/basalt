# shellcheck shell=bash

do-add() {
	util.init_command

	local flag_branch=
	local -a pkgs=()
	for arg; do case "$arg" in
	--branch=*)
		IFS='=' read -r discard flag_branch <<< "$arg"

		if [ -z "$flag_branch" ]; then
			die "Branch cannot be empty"
		fi
		;;
	-*)
		die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	else
		for repoSpec in "${pkgs[@]}"; do
			do-actual-add "$repoSpec" "$flag_branch"
		done
	fi
}

do-actual-add() {
	local repoSpec="$1"
	local flag_branch="$2"

	if [[ -d "$repoSpec" && "${repoSpec::1}" == / ]]; then
		die "Identifier '$repoSpec' is a directory, not a package"
	fi

	util.extract_data_from_input "$repoSpec"
	local uri="$REPLY1"
	local site="$REPLY2"
	local package="$REPLY3"
	local ref="$REPLY4"

	# TODO: remove this condition as linked packages should be stored in a different directory
	if [ "$site" = 'local' ]; then
		die "Cannot install packages owned by username 'local' because that conflicts with linked packages"
	fi

	if [ -e "$BASALT_PACKAGES_PATH/$site/$package" ]; then
		if [ "$BASALT_MODE" = local ]; then
			log.info "Skipping '$site/$package' as it's already present"
			return
		else
			log.info "Skipping '$site/$package' as it's already present"
			return
		fi
	else
		log.info "Adding '$repoSpec'"
	fi

	plumbing.git-clone "$uri" "$site/$package" "$ref" "$flag_branch"
	plumbing.add-dependencies "$site/$package"
	plumbing.symlink-bins "$site/$package"
	plumbing.symlink-completions "$site/$package"
	plumbing.symlink-mans "$site/$package"
}
