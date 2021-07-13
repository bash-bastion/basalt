# shellcheck shell=bash

abstract_bins_did=no

abstract.bins() {
	local action="$1"
	local id="$2"
	ensure.non_zero 'action' "$action"
	ensure.non_zero 'id' "$id"

	local -a bins=()
	local remove_extension=

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
				for file in "$BPM_PACKAGES_PATH/$id/$dir"/*; do
					abstract.bins_do_action "$action" "$file" "$remove_extensions"
				done
			done

			return
		fi

		abstract.bins_search_heuristics "$action" "$id" "$remove_extensions"
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
					log.warn "Executable file '$file' not found in repository. Skipping"
				else
					abstract.bins_do_action "$action" "$full_path" "$remove_extensions"
				fi
			done
		else
			abstract.bins_search_heuristics "$action" "$id" "$remove_extensions"
		fi
	else
		abstract.bins_search_heuristics "$action" "$id" "$remove_extensions"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
# @arg $2 Whether to remove extensions
abstract.bins_search_heuristics() {
	local action="$1"
	local id="$2"
	local remove_extensions="$3"

	if [ -d "$BPM_PACKAGES_PATH/$id/bin" ]; then
		for file in "$BPM_PACKAGES_PATH/$id"/bin/*; do
			abstract.bins_do_action "$action" "$file" "$remove_extensions"
		done
	elif [ -d "$BPM_PACKAGES_PATH/$id/bins" ]; then
		for file in "$BPM_PACKAGES_PATH/$id"/bins/*; do
			abstract.bins_do_action "$action" "$file" "$remove_extensions"
		done
	else
		for file in "$BPM_PACKAGES_PATH/$id"/*; do
			if [ -x "$file" ]; then
				abstract.bins_do_action "$action" "$file" "$remove_extensions"
			fi
		done
	fi
}

# @description Symlink the bin file to the correct location or
# remove the symlink
# @arg $1 The full path of the executable
# @arg $2 Whether to remove extensions
abstract.bins_do_action() {
	local action="$1"
	local fullBinFile="$2"
	local remove_extensions="$3"

	if [ "$abstract_bins_did" = no ]; then
		abstract_bins_did='yes'

		case "$action" in
			link) printf '%s\n' "  -> Linking bin files" ;;
			unlink) printf '%s\n' "  -> Unlinking bin files" ;;
		esac
	fi

	local binName="${fullBinFile##*/}"

	if [[ "${remove_extensions:-no}" == @(yes|true) ]]; then
		binName="${binName%%.*}"
	fi

	case "$action" in
		link)
			mkdir -p "$BPM_INSTALL_BIN"
			ln -sf "$fullBinFile" "$BPM_INSTALL_BIN/$binName"
			chmod +x "$BPM_INSTALL_BIN/$binName"
			;;
		unlink)
			if [ -f "$BPM_INSTALL_BIN/$binName" ]; then
				unlink "$BPM_INSTALL_BIN/$binName"
			fi
			;;
	esac
}
