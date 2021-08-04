# shellcheck shell=bash

do-add() {
	local flag_ssh='no'
	local flag_all='no'
	local flag_branch=

	util.setup_mode

	local -a pkgs=()
	for arg; do
		case "$arg" in
		--ssh)
			flag_ssh='yes'
			;;
		--all)
			flag_all='yes'
			;;
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
		esac
	done

	if [[ "$BPM_IS_LOCAL" == no && "$flag_all" == yes ]]; then
		die "Cannot pass '--all' without a 'bpm.toml' file"
	fi

	if [ "$flag_all" = yes ]; then
		local bpm_toml_file="$BPM_ROOT/bpm.toml"

		if (( ${#pkgs[@]} > 0 )); then
			die "No packages may be supplied when using '--all'"
		fi

		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
			log.info "Adding all dependencies"

			for pkg in "${REPLIES[@]}"; do
				do-actual-add "$pkg" "$flag_ssh" "$flag_branch"
			done
		else
			log.warn "No dependencies specified in 'dependencies' key"
		fi

		return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	fi

	for repoSpec in "${pkgs[@]}"; do
		do-actual-add "$repoSpec" "$flag_ssh" "$flag_branch"
	done
}

do-actual-add() {
	local repoSpec="$1"
	local flag_ssh="$2"
	local flag_branch="$3"

	if [[ -d "$repoSpec" && "${repoSpec::1}" == / ]]; then
		die "Identifier '$repoSpec' is a directory, not a package"
	fi

	util.extract_data_from_input "$repoSpec" "$flag_ssh"
	local uri="$REPLY1"
	local site="$REPLY2"
	local package="$REPLY3"
	local ref="$REPLY4"

	if [ "$site" = 'local' ]; then
		die "Cannot install packages owned by username 'local' because that conflicts with linked packages"
	fi

	log.info "Adding '$repoSpec'"
	do-plumbing-clone "$uri" "$site/$package" "$ref" "$flag_branch"
	do-plumbing-add-deps "$site/$package"
	do-plumbing-link-bins "$site/$package"
	do-plumbing-link-completions "$site/$package"
	do-plumbing-link-man "$site/$package"

	# Install transitive dependencies
	local subDep="$BPM_PACKAGES_PATH/$site/$package"

	if [[ ! -d "$subDep" && -n "${BPM_MODE_TEST+x}" ]]; then
		# During some tests, plumbing-* or Git commands may be stubbed,
		# so the package may not actually be cloned
		return
	fi

	local oldWd="$PWD"
	ensure.cd "$subDep"
	local bpm_toml_file="$subDep/bpm.toml"
	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
			do-add --all
		fi
	fi
	ensure.cd "$oldWd"
}
