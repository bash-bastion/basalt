# shellcheck shell=bash

do-upgrade() {
	util.init_command

	local upgrade_bpm='no'
	local flag_all='no'
	local -a pkgs=()
	for arg; do
		case "$arg" in
		bpm)
			upgrade_bpm='yes'
			;;
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

	if [ "$flag_all" = yes ] && (( ${#pkgs[@]} > 0 )); then
		die "No packages may be supplied when using '--all'"
	fi

	if [ "$BPM_MODE" = local ] && (( ${#pkgs[@]} > 0 )); then
		die "Subcommands must use the '--all' flag when a 'bpm.toml' file is present"
	fi

	if [[ $upgrade_bpm == yes && "$flag_all" = yes ]]; then
		die "Upgrading bpm and using '--all' are mutually exclusive behaviors"
	fi

	if [[ $upgrade_bpm == yes && "$BPM_MODE" == local ]]; then
		die "Cannot upgrade bpm with a local 'bpm.toml' file"
	fi

	if [ "$upgrade_bpm" = 'yes' ]; then
		if (( ${#pkgs[@]} > 0 )); then
			die 'Packages cannot be upgraded at the same time as bpm'
		fi

		if [ -d "$PROGRAM_LIB_DIR/../../.git" ]; then
			git -C "$PROGRAM_LIB_DIR/../.." pull

			# '--init' wasn't included in the original installation instructions
			# and submodules might be added in the future
			git -C "$PROGRAM_LIB_DIR/../.." submodule init
			git -C "$PROGRAM_LIB_DIR/../.." submodule sync --recursive
			git -C "$PROGRAM_LIB_DIR/../.." submodule update --recursive --merge
		else
			log.error "bpm is not a Git repository"
		fi

		return
	fi

	# TODO: test this
	if [ "$flag_all" = yes ]; then
		local bpm_toml_file="$BPM_LOCAL_PROJECT_DIR/bpm.toml"

		if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
			log.info "Adding all dependencies"

			for pkg in "${REPLIES[@]}"; do
				# TODO: only upgrade to latest as specified in bpm.toml
				do-upgrade "$pkg"
			done

			else
				log.warn "No dependencies specified in 'dependencies' key"
			fi

			return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	fi

	for repoSpec; do
		util.extract_data_from_input "$repoSpec"
		local site="$REPLY2"
		local package="$REPLY3"
		local ref="$REPLY4"

		if [ -n "$ref" ]; then
			die "Refs must be omitted when upgrading packages. Remove ref '@$ref'"
		fi

		if [ -L "$BPM_PACKAGES_PATH/$site/$package" ]; then
			die "Package '$site/$package' is locally symlinked and cannot be upgraded through Git"
		elif [ -d "$BPM_PACKAGES_PATH/$site/$package" ]; then
			do_actual_upgrade "$site/$package"
		else
			die "Package '$site/$package' is not installed"
		fi
	done
}

do_actual_upgrade() {
	local id="$1"

	log.info "Upgrading '$id'"
	plumbing.remove-dependencies "$id"
	plumbing.unsymlink-bins "$id"
	plumbing.unsymlink-completions "$id"
	plumbing.unsymlink-mans "$id"

	printf '  -> %s\n' "Fetching repository updates and merging"
	local git_output=
	if ! git_output="$(git -C "$BPM_PACKAGES_PATH/$id" pull 2>&1)"; then
		log.error "Could not update Git repository"
		printf "  -> %s\n" "Git output:"
		printf "    -> %s\n" "${git_output%.}"
		exit 1
	fi

	if [ -n "${BPM_IS_TEST+x}" ]; then
		printf "%s\n" "$git_output"
	fi

	plumbing.add-dependencies "$id"
	plumbing.symlink-bins "$id"
	plumbing.symlink-completions "$id"
	plumbing.symlink-mans "$id"
}
