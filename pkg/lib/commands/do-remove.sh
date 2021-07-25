# shellcheck shell=bash

do-remove() {
	local flag_all='no'

	util.setup_mode

	local -a pkgs=()
	for arg; do
		case "$arg" in
		--all)
			flag_all='yes'
			;;
		-*)
			die "Flag '$arg' not recognized"
			;;
		*)
			pkgs+=("$arg")
			;;
		esac
	done

	if [ "$flag_all" = yes ]; then
		local bpm_toml_file="$BPM_ROOT/bpm.toml"

		if (( ${#pkgs[@]} > 0 )); then
			die "You must not supply any packages when using '--all'"
		fi

		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
			log.info "Removing all dependencies"

			for pkg in "${REPLIES[@]}"; do
				do-remove "$pkg"
			done
		else
			log.warn "No dependencies specified in 'dependencies' key"
		fi

		return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec in "${pkgs[@]}"; do
		util.extract_data_from_input "$repoSpec"
		local site="$REPLY2"
		local package="$REPLY3"

		if [ -d "$BPM_PACKAGES_PATH/$site/$package" ]; then
			do_actual_removal "$site/$package"
		elif [ -e "$BPM_PACKAGES_PATH/$site/$package" ]; then
			rm -f "$BPM_PACKAGES_PATH/$site/$package"
		else
			die "Package '$site/$package' is not installed"
		fi
	done
}

do_actual_removal() {
	local id="$1"

	log.info "Removing '$id'"
	do-plumbing-unlink-man "$id"
	do-plumbing-unlink-bins "$id"
	do-plumbing-unlink-completions "$id"

	if [ "${id%%/*}" = 'local' ]; then
		printf '%s\n' "  -> Unsymlinking directory"
		unlink "$BPM_PACKAGES_PATH/$id"
	else
		printf '%s\n' "  -> Deleting Git repository"
		rm -rf "${BPM_PACKAGES_PATH:?}/$id"
		if ! rmdir -p "${BPM_PACKAGES_PATH:?}/${id%/*}" &>/dev/null; then
			# Do not exit on "failure"
			:
		fi
	fi

}
