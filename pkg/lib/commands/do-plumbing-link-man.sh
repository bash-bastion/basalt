# shellcheck shell=bash

do-plumbing-link-man() {
	local package="$1"
	ensure.non_zero 'package' "$package"
	ensure.package_exists "$package"

	# TODO: only print when actually linking
	log.info "Linking man files for '$package'"

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
						symlink_manfile "$file"
					elif [ -d "$file" ]; then
						for actualFile in "$file"/*; do
							if [ -f "$actualFile" ]; then
								symlink_manfile "$actualFile"
							fi
						done
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
		if [ -f "$file" ]; then
			symlink_manfile "$file"
		elif [ -d "$file" ]; then
			for actualFile in "$file"/*; do
				if [ -f "$actualFile" ]; then
					symlink_manfile "$actualFile"
				fi
			done
		fi
	done
}

# @arg $1 The man file to symlink
symlink_manfile() {
	local full_man_file="$1"

	local manFile="${full_man_file##*/}"

	local regex="\.([1-9])\$"
	if [[ "$full_man_file" =~ $regex ]]; then
		local n="${BASH_REMATCH[1]}"
		mkdir -p "$BPM_INSTALL_MAN/man$n"
		ln -sf "$full_man_file" "$BPM_INSTALL_MAN/man$n/$manFile"
	fi
}
