# shellcheck shell=bash

# TODO: cleanup
do-plumbing-link-man() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local -a mans=()

	local bpmTomlFile="$BPM_PACKAGES_PATH/$package/bpm.toml"

	if [ -f "$bpmTomlFile" ]; then
		if util.get_toml_array "$bpmTomlFile" 'manDirs'; then
			local -a newMans=()
			for dir in "${REPLIES[@]}"; do
				for manFile in "$BPM_PACKAGES_PATH/$package/$dir"/*; do
					manFile="${manFile##*/}"

					local regex="\.([1-9])\$"
					if [[ "$manFile" =~ $regex ]]; then
						local n="${BASH_REMATCH[1]}"
						mkdir -p "$BPM_INSTALL_MAN/man$n"
						ln -sf "$BPM_PACKAGES_PATH/$package/$dir/$manFile" "$BPM_INSTALL_MAN/man$n/$manFile"
					fi
				done
			done
		fi

		return
	fi

	local files1=("$BPM_PACKAGES_PATH/$package"/man/*)
	files1=("${files1[@]##*/}")

	local regex="\.([1-9])\$"
	for file in "${files1[@]}"; do
		if [[ "$file" =~ $regex ]]; then
			local n="${BASH_REMATCH[1]}"
			mkdir -p "$BPM_INSTALL_MAN/man$n"
			ln -sf "$BPM_PACKAGES_PATH/$package/man/$file" "$BPM_INSTALL_MAN/man$n/$file"
		fi
	done

	local files2=("$BPM_PACKAGES_PATH/$package"/*)
	files2=("${files2[@]##*/}")

	local regex="\.([1-9])\$"
	for file in "${files2[@]}"; do
		if [[ "$file" =~ $regex ]]; then
			local n="${BASH_REMATCH[1]}"
			mkdir -p "$BPM_INSTALL_MAN/man$n"
			ln -sf "$BPM_PACKAGES_PATH/$package/$file" "$BPM_INSTALL_MAN/man$n/$file"
		fi
	done
}
