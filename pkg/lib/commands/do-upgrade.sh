# shellcheck shell=bash

do-upgrade() {
	local upgrade_bpm='no'

	util.setup_mode

	local -a pkgs=()
	for arg; do
		case "$arg" in
		bpm)
			upgrade_bpm='yes'
			;;
		*)
			pkgs+=("$arg")
			;;
		esac
	done

	if [ "$upgrade_bpm" = 'yes' ]; then
		if (( ${#pkgs[@]} > 0 )); then
			die 'You cannot upgarde bpm and its packages at the same time'
		fi

		if [ -d "$PROGRAM_LIB_DIR/../../.git" ]; then
			git -C "$PROGRAM_LIB_DIR/../.." pull
		else
			log.error "bpm is not a Git repository"
		fi

		return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		if [[ -d "$repoSpec" && "${repoSpec::1}" == / ]]; then
			die "Identifier '$repoSpec' is a directory, not a package"
		fi

		util.extract_data_from_input "$repoSpec"
		local site="$REPLY2"
		local package="$REPLY3"
		local ref="$REPLY4"

		do_actual_upgrade "$site/$package"
	done
}

do_actual_upgrade() {
	local id="$1"

	if [ ! -d "$BPM_PACKAGES_PATH/$id/.git" ]; then
		die "Package at '$BPM_PACKAGES_PATH/$id' is not a Git repository"
	fi

	log.info "Upgrading '$id'"
	do-plumbing-remove-deps "$id"
	do-plumbing-unlink-bins "$id"
	do-plumbing-unlink-completions "$id"
	do-plumbing-unlink-man "$id"
	local git_output=

	if ! git_output="$(git -C "$BPM_PACKAGES_PATH/$id" pull 2>&1)"; then
		log.error "Could not update Git repository"
		printf "%s\n" "$git_output"
		exit 1
	fi

	if [ -n "${BPM_MODE_TEST+x}" ]; then
		printf "%s\n" "$git_output"
	fi

	do-plumbing-add-deps "$id"
	do-plumbing-link-bins "$id"
	do-plumbing-link-completions "$id"
	do-plumbing-link-man "$id"
}
