# shellcheck shell=bash

# @arg $1 The man file to symlink
link-man-n-file() {
	local fullManFile="$1"

	local manFile="${fullManFile##*/}"

	local regex="\.([1-9])\$"
	if [[ "$fullManFile" =~ $regex ]]; then
		local n="${BASH_REMATCH[1]}"
		mkdir -p "$BPM_INSTALL_MAN/man$n"
		ln -sf "$fullManFile" "$BPM_INSTALL_MAN/man$n/$manFile"
	fi
}

# @description Automatically locate man files in the project and symlink them.
# This is used when no directories are given in any config files
auto-symlink-man() {
	for file in "$BPM_PACKAGES_PATH/$package"/{,man/}*; do
		link-man-n-file "$file"
	done
}

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
						link-man-n-file "$file"
					elif [ -d "$file" ]; then
						:
						# TODO: Implement 2
					fi
				done
			done
		else
			auto-symlink-man "$package"
		fi
	else
		auto-symlink-man "$package"
	fi
}
