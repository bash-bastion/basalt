# shellcheck shell=bash

do-plumbing-link-bins() {
	local package="$1"
	ensure.nonZero 'package' "$package"
	ensure.packageExists "$package"

	log.info "Linking bin files for '$package'"

	# We want this to be visible to the other functions
	declare -g remove_extension=
	local -a bins=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"

	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'binDirs'; then
			for dir in "${REPLIES[@]}"; do
				for file in "$BPM_PACKAGES_PATH/$package/$dir"/*; do
					symlink_binfile "$file"
				done
			done
		else
			fallback_symlink_bins "$package"
		fi
	elif [ -f "$packageShFile" ]; then
		if util.extract_shell_variable "$packageShFile" 'REMOVE_EXTENSION'; then
			remove_extension="$REPLY"
		fi

		if util.extract_shell_variable "$packageShFile" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"

			for file in "${bins[@]}"; do
				symlink_binfile "$BPM_PACKAGES_PATH/$package/$file"
			done
		else
			fallback_symlink_bins "$package"
		fi
	else
		fallback_symlink_bins "$package"
	fi
}

# @description Use heuristics to locate and symlink the bin files. This is ran when
# the user does not supply any bin files/dirs with any config
# @arg $1 package
fallback_symlink_bins() {
	declare -ga REPLIES=()

	local package="$1"

	local bins=()

	if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
		for file in "$BPM_PACKAGES_PATH/$package"/bin/*; do
			symlink_binfile "$file"
		done
	else
		for file in "$BPM_PACKAGES_PATH/$package"/*; do
			if [ -x "$file" ]; then
				symlink_binfile "$file"
			fi
		done
	fi
}

# @description Actually symlink the bin file to the correct location
# @arg $1 The full path of the executable
symlink_binfile() {
	local fullBinFile="$1"

	local binName="${fullBinFile##*/}"

	if [[ "${remove_extension:-no}" == @(yes|true) ]]; then
		binName="${binName%%.*}"
	fi

	mkdir -p "$BPM_INSTALL_BIN"
	ln -sf "$fullBinFile" "$BPM_INSTALL_BIN/$binName"
	chmod +x "$BPM_INSTALL_BIN/$binName"
}
