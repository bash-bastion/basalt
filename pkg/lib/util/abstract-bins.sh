# shellcheck shell=bash

abstract.bins() {
	local action="$1"
	local package="$2"
	ensure.non_zero 'action' "$action"
	ensure.non_zero 'package' "$package"

	case "$action" in
	link)
		log.info "Linking bin files for '$package'"
		;;
	unlink)
		log.info "Unlinking bin files for '$package'"
		;;
	esac

	local -a bins=()
	local remove_extension=

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_string "$bpm_toml_file" 'binRemoveExtensions'; then
			if [ "$REPLY" = 'yes' ]; then
				remove_extensions='yes'
			fi
		fi

		if util.get_toml_array "$bpm_toml_file" 'binDirs'; then
			for dir in "${REPLIES[@]}"; do
				for file in "$BPM_PACKAGES_PATH/$package/$dir"/*; do
					abstract.bins_do_action "$action" "$file" "$remove_extensions"
				done
			done

			return
		fi

		abstract.bins_search_heuristics "$action" "$package" "$remove_extensions"
	elif [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'REMOVE_EXTENSION'; then
			remove_extensions="$REPLY"
		fi

		if util.extract_shell_variable "$package_sh_file" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"

			for file in "${bins[@]}"; do
				abstract.bins_do_action "$action" "$BPM_PACKAGES_PATH/$package/$file" "$remove_extensions"
			done
		else
			abstract.bins_search_heuristics "$action" "$package" "$remove_extensions"
		fi
	else
		abstract.bins_search_heuristics "$action" "$package" "$remove_extensions"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
# @arg $2 Whether to remove extensions
abstract.bins_search_heuristics() {
	local action="$1"
	local package="$2"
	local remove_extensions="$3"

	if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
		for file in "$BPM_PACKAGES_PATH/$package"/bin/*; do
			abstract.bins_do_action "$action" "$file" "$remove_extensions"
		done
	elif [ -d "$BPM_PACKAGES_PATH/$package/bins" ]; then
		for file in "$BPM_PACKAGES_PATH/$package"/bins/*; do
			abstract.bins_do_action "$action" "$file" "$remove_extensions"
		done
	else
		for file in "$BPM_PACKAGES_PATH/$package"/*; do
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
