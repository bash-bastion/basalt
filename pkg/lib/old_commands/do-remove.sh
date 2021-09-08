# shellcheck shell=bash

do-remove() {
	util.init_command

	local flag_all='no'
	local flag_force='no'
	local -a pkgs=()
	for arg; do case "$arg" in
	--all)
		flag_all='yes'
		;;
	--force)
		flag_force='yes'
		;;
	-*)
		die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	if [ "$flag_all" = yes ] && (( ${#pkgs[@]} > 0 )); then
		die "No packages may be supplied when using '--all'"
	fi

	if [ "$BASALT_MODE" = local ] && (( ${#pkgs[@]} > 0 )); then
		die "Subcommands must use the '--all' flag when a 'basalt.toml' file is present"
	fi

	if [[ $flag_all == yes && $flag_force == yes ]]; then
		die "Flags '--all' and '--force' are mutually exclusive"
	fi

	if [ "$flag_all" = yes ]; then
		local basalt_toml_file="$BASALT_LOCAL_PROJECT_DIR/basalt.toml"

		if util.get_toml_array "$basalt_toml_file" 'dependencies'; then
			log.info "Removing all dependencies"

			for pkg in "${REPLIES[@]}"; do
				do-remove "$pkg"
			done
		else
			case "$?" in
			1)
				log.warn "No dependencies specified in 'dependencies' key"
				;;
			2)
				if [ "$flag_force" = 'no' ]; then
					exit 1
				fi
				;;
			esac
		fi

		return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	fi

	if [ "$flag_force" = yes ] && (( ${#pkgs[@]} > 1 )); then
		die "Only one package may be specified when --force is passed"
	fi

	for repoSpec in "${pkgs[@]}"; do
		util.extract_data_from_input "$repoSpec"
		local site="$REPLY2"
		local package="$REPLY3"
		local ref="$REPLY4"

		if [ -n "$ref" ]; then
			die "Refs must be omitted when removing packages. Remove ref '@$ref'"
		fi

		if [ -d "$BASALT_PACKAGES_PATH/$site/$package" ]; then
			if [ "$flag_force" = yes ]; then
				log.info "Force removing '$site/$package'"
				rm -rf "${BASALT_PACKAGES_PATH:?}/$site/$package"
				do-prune
			else
				do_actual_removal "$site/$package"
			fi
		elif [ -e "$BASALT_PACKAGES_PATH/$site/$package" ]; then
			rm -f "$BASALT_PACKAGES_PATH/$site/$package"
		else
			die "Package '$site/$package' is not installed"
		fi
	done
}

do_actual_removal() {
	local id="$1"

	log.info "Removing '$id'"
	plumbing.unsymlink-mans "$id"
	plumbing.unsymlink-bins "$id"
	plumbing.unsymlink-completions "$id"

	if [ "${id%%/*}" = 'local' ]; then
		printf '  -> %s\n' "Unsymlinking directory"
		if ! unlink "$BASALT_PACKAGES_PATH/$id"; then
			die "Unlink '$BASALT_PACKAGES_PATH/$id' unexpectedly failed"
		fi
	else
		printf '  -> %s\n' "Removing Git repository"
		rm -rf "${BASALT_PACKAGES_PATH:?}/$id"
		if ! rmdir -p "${BASALT_PACKAGES_PATH:?}/${id%/*}" &>/dev/null; then
			# Do not exit on "failure"
			:
		fi
	fi
}
