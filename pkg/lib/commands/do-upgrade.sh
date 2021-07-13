# shellcheck shell=bash

do-upgrade() {
	local upgrade_bpm='no'

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
		# If is local directory
		if [ -d "$repoSpec" ]; then
			local dir=
			dir="$(util.readlink "$repoSpec")"
			dir="${dir%/}"

			util.extract_data_from_package_dir "$dir"
			local site="$REPLY1"
			local package="$REPLY2/$REPLY3"

			do_actual_upgrade "$site/$package"
		else
			util.extract_data_from_input "$repoSpec"
			local site="$REPLY2"
			local package="$REPLY3"
			local ref="$REPLY4"

			do_actual_upgrade "$site/$package"
		fi
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
		printf "%s" "$git_output"
		exit 1
	fi

	if [ -n "${BPM_MODE_TEST+x}" ]; then
		printf "%s" "$git_output"
	fi

	do-plumbing-add-deps "$id"
	do-plumbing-link-bins "$id"
	do-plumbing-link-completions "$id"
	do-plumbing-link-man "$id"
}
