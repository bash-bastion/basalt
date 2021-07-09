# shellcheck shell=bash

do-plumbing-link-man() {
	local package="$1"
	ensure.nonZero 'package' "$package"
	ensure.packageExists "$package"

	# TODO: only print when actually linking
	log.info "Linking man files for '$package'"

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"

	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'manDirs'; then
			for dir in "${REPLIES[@]}"; do
				local fullDir="$BPM_PACKAGES_PATH/$package/$dir"

				# 'file' can be
				# 1. A man file
				# 2. A directory (man1, man2), that contains man files
				for file in "$fullDir"/*; do
					if [ -f "$file" ]; then
						symlink-manfile "$file"
					elif [ -d "$file" ]; then
						:
						# TODO: Implement 2
					fi
				done
			done
		else
			fallback_symlink_mans "$package"
		fi
	else
		fallback_symlink_mans "$package"
	fi
}

# @description Use heuristics to locate and symlink man files. This is ran when
# the user does not supply any man files/dirs with any config
fallback_symlink_mans() {
	for file in "$BPM_PACKAGES_PATH/$package"/{,man/}*; do
		symlink-manfile "$file"
	done
}

# @arg $1 The man file to symlink
symlink-manfile() {
	local fullManFile="$1"

	local manFile="${fullManFile##*/}"

	local regex="\.([1-9])\$"
	if [[ "$fullManFile" =~ $regex ]]; then
		local n="${BASH_REMATCH[1]}"
		mkdir -p "$BPM_INSTALL_MAN/man$n"
		ln -sf "$fullManFile" "$BPM_INSTALL_MAN/man$n/$manFile"
	fi
}
