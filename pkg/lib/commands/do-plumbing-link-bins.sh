# shellcheck shell=bash

# @description Get all executable scripts of repository automatically
# @arg $1 Name of package
auto-collect-bins() {
	declare -ga REPLIES=()

	local package="$1"

	local bins=()
	if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
		bins=("$BPM_PACKAGES_PATH/$package"/bin/*)
		bins=("${bins[@]##*/}")
		bins=("${bins[@]/#/bin/}")
	else
		# TODO: ignore 'uninstall.sh', 'install.sh' scripts
		readarray -t bins < <(find "$BPM_PACKAGES_PATH/$package" -maxdepth 1 -mindepth 1 -perm -u+x -type f -or -type l)
		bins=("${bins[@]##*/}")
	fi

	REPLIES=("${bins[@]}")
}

do-plumbing-link-bins() {
	local package="$1"
	ensure.nonZero 'package' "$package"
	ensure.packageExists "$package"

	log.info "Linking bin files for '$package'"

	local remove_extension=
	local -a bins=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"
	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"

	# Get bin directories
	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'binDirs'; then
			local -a newBins=()
			for dir in "${REPLIES[@]}"; do
				newBins=("$BPM_PACKAGES_PATH/$package/$dir"/*)
				newBins=("${newBins[@]##*/}")
				newBins=("${newBins[@]/#/"$dir"/}")
			done
			bins+=("${newBins[@]}")
		else
			auto-collect-bins "$package"
			bins=("${REPLIES[@]}")
		fi
	elif [ -f "$packageShFile" ]; then
		if util.extract_shell_variable "$packageShFile" 'REMOVE_EXTENSION'; then
			remove_extension="$REPLY"
		fi

		if util.extract_shell_variable "$packageShFile" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"
		else
			auto-collect-bins "$package"
			bins=("${REPLIES[@]}")
		fi
	else
		auto-collect-bins "$package"
		bins=("${REPLIES[@]}")
	fi

	# Do linking for each bin file
	for bin in "${bins[@]}"; do
		local name="${bin##*/}"

		if [[ "${remove_extension:-no}" == @(yes|true) ]]; then
			name="${name%%.*}"
		fi

		mkdir -p "$BPM_INSTALL_BIN"
		ln -sf "$BPM_PACKAGES_PATH/$package/$bin" "$BPM_INSTALL_BIN/$name"
		chmod +x "$BPM_INSTALL_BIN/$name"
	done
}
