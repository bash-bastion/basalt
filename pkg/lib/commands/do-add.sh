# shellcheck shell=bash

do-add() {
	local flag_ssh='no'
	local flag_all='no'

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
			log.info "Adding all dependencies"

			for pkg in "${REPLIES[@]}"; do
				do-add "$pkg"
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
		do-plumbing-clone "$uri" "$site/$package" $ref
		do-plumbing-add-deps "$site/$package"
		do-plumbing-link-bins "$site/$package"
		do-plumbing-link-completions "$site/$package"
		do-plumbing-link-man "$site/$package"
	done
}
