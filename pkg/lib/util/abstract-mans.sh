# shellcheck shell=bash

abstract.mans() {
	local action="$1"
	local package="$2"
	ensure.non_zero 'action' "$action"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	# TODO: only print when actually linking
	case "$action" in
	link)
		log.info "Linking man files for '$package'"
		;;
	unlink)
		log.info "Unlinking man files for '$package'"
		;;
	esac

	local bpm_toml_file="$BPM_PACKAGES_PATH/$package/bpm.toml"

	if [ -f "$bpm_toml_file" ]; then
		if util.get_toml_array "$bpm_toml_file" 'manDirs'; then
			for dir in "${REPLIES[@]}"; do
				local full_dir="$BPM_PACKAGES_PATH/$package/$dir"

				# 'file' can be
				# 1. A man file
				# 2. A directory (man1, man2), that contains man files
				for file in "$full_dir"/*; do
					if [ -f "$file" ]; then
						abstract.mans_do_action "$action" "$file"
					elif [ -d "$file" ]; then
						for actualFile in "$file"/*; do
							if [ -f "$actualFile" ]; then
								abstract.mans_do_action "$action" "$actualFile"
							fi
						done
					fi
				done
			done
		else
			abstract.mans_search_heuristics "$action" "$package"
		fi
	else
		abstract.mans_search_heuristics "$action" "$package"
	fi
}

# @description Use heuristics to locate and symlink man files. This is ran when
# the user does not supply any man files/dirs with any config
abstract.mans_search_heuristics() {
	local action="$1"
	local package="$2"

	for file in "$BPM_PACKAGES_PATH/$package"/{,man/}*; do
		if [ -f "$file" ]; then
			abstract.mans_do_action "$action" "$file"
		elif [ -d "$file" ]; then
			for actualFile in "$file"/*; do
				if [ -f "$actualFile" ]; then
					abstract.mans_do_action "$action" "$actualFile"
				fi
			done
		fi
	done
}

# @arg $1 The man file to symlink or remove. Not all the files passed
# in here are man pages, which is why the regex check exists, to extract
# the file ending (and the man category)
abstract.mans_do_action() {
	local action="$1"
	local full_man_file="$2"

	local manFile="${full_man_file##*/}"

	local regex="\.([1-9])\$"
	if [[ "$full_man_file" =~ $regex ]]; then
		local n="${BASH_REMATCH[1]}"

		case "$action" in
			link)
				mkdir -p "$BPM_INSTALL_MAN/man$n"
				ln -sf "$full_man_file" "$BPM_INSTALL_MAN/man$n/$manFile"
				;;
			unlink)
				# Because 'abstract.mans_search_heuristics' sometimes repeats
				# directories, and sometimes the stat's are out of dates, we add this
				# check in case a file was deleted in the meantime
				if [ -f "$BPM_INSTALL_MAN/man$n/$manFile" ]; then
					unlink "$BPM_INSTALL_MAN/man$n/$manFile"
				fi
				;;
		esac
	fi
}
