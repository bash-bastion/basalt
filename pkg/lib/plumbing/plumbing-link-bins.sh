# shellcheck shell=bash

plumbing.symlink-bins() {
	local id="$1"
	ensure.non_zero 'id' "$id"

	plumbing.bins_action 'link' "$id"
}

plumbing.unsymlink-bins() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	plumbing.bins_action 'unlink' "$pkg"
}

plumbing.bins_action() {
	local action="$1"
	local id="$2"
	ensure.non_zero 'action' "$action"
	ensure.non_zero 'id' "$id"

	abstract_bins_did=no

	local -a bins=()
	local remove_extensions=

	local bpm_toml_file="$BPM_PACKAGES_PATH/$id/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$id/package.sh"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_string "$bpm_toml_file" 'binRemoveExtensions'; then
			if [ "$REPLY" = 'yes' ]; then
				remove_extensions='yes'
			fi
		fi

		if util.get_toml_array "$bpm_toml_file" 'binDirs'; then
			for dir in "${REPLIES[@]}"; do
				local full_path="$BPM_PACKAGES_PATH/$id/$dir"
				if [ -f "$full_path" ]; then
					die "Specified file '$dir' in bpm.toml; only directories are valid"
				elif [ ! -d "$full_path" ]; then
					log.warn "Directory '$dir' with executable files not found. Skipping"
				else
					for file in "$full_path"/*; do
						plumbing.bins_action_do_action "$action" "$file" "$remove_extensions"
					done
				fi
			done

			return
		fi

		plumbing.bins_action_search_heuristics "$action" "$id" "$remove_extensions"
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'REMOVE_EXTENSION'; then
			remove_extensions="$REPLY"
		fi

		if util.extract_shell_variable "$package_sh_file" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"

			for file in "${bins[@]}"; do
				local full_path="$BPM_PACKAGES_PATH/$id/$file"
				if [ -d "$full_path" ]; then
					die "Specified directory '$file' in package.sh; only files are valid"
				elif [ ! -f "$full_path" ]; then
					log.warn "Executable file '$file' not found. Skipping"
				else
					plumbing.bins_action_do_action "$action" "$full_path" "$remove_extensions"
				fi
			done
		else
			plumbing.bins_action_search_heuristics "$action" "$id" "$remove_extensions"
		fi
	else
		plumbing.bins_action_search_heuristics "$action" "$id" "$remove_extensions"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
# @arg $2 Whether to remove extensions
plumbing.bins_action_search_heuristics() {
	local action="$1"
	local id="$2"
	local remove_extensions="$3"

	if [ -d "$BPM_PACKAGES_PATH/$id/bin" ]; then
		for file in "$BPM_PACKAGES_PATH/$id"/bin/*; do
			plumbing.bins_action_do_action "$action" "$file" "$remove_extensions"
		done
	elif [ -d "$BPM_PACKAGES_PATH/$id/bins" ]; then
		for file in "$BPM_PACKAGES_PATH/$id"/bins/*; do
			plumbing.bins_action_do_action "$action" "$file" "$remove_extensions"
		done
	else
		for file in "$BPM_PACKAGES_PATH/$id"/*; do
			if [[ -f "$file" && -x "$file" ]]; then
				plumbing.bins_action_do_action "$action" "$file" "$remove_extensions"
			fi
		done
	fi
}

# @description Symlink the bin file to the correct location or
# remove the symlink
# @arg $1 The full path of the executable
# @arg $2 Whether to remove extensions
plumbing.bins_action_do_action() {
	local action="$1"
	local fullBinFile="$2"
	local remove_extensions="$3"

	if [ "$abstract_bins_did" = no ]; then
		abstract_bins_did='yes'

		case "$action" in
			link) printf '  -> %s\n' "Symlinking bin files" ;;
			unlink) printf '  -> %s\n' "Unsymlinking bin files" ;;
		esac
	fi

	local binName="${fullBinFile##*/}"

	if [[ "${remove_extensions:-no}" == @(yes|true) ]]; then
		binName="${binName%%.*}"
	fi

	case "$action" in
		link)
			mkdir -p "$BPM_INSTALL_BIN"

			if [ -L "$BPM_INSTALL_BIN/$binName" ]; then
				log.error "Skipping '$binName' since an existing symlink with the same name already exists"
			else
				ln -sf "$fullBinFile" "$BPM_INSTALL_BIN/$binName"
				chmod +x "$BPM_INSTALL_BIN/$binName"
			fi
			;;
		unlink)
			if ! unlink "$BPM_INSTALL_BIN/$binName"; then
				die "Unlink failed, but was expected to succeed"
			fi
			;;
	esac
}
