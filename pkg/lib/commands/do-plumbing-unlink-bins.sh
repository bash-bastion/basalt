# shellcheck shell=bash

do-plumbing-unlink-bins() {
	local package="$1"
	ensure.non_zero 'package' "$package"

	log.info "Unlinking bin files for '$package'"

	local -a bins=()
	local remove_extension=

	local package_sh_file="$BPM_PACKAGES_PATH/$package/package.sh"
	if [ -f "$package_sh_file" ]; then
		if util.extract_shell_variable "$package_sh_file" 'BINS'; then
			IFS=':' read -ra bins <<< "$REPLY"
		fi

		if util.extract_shell_variable "$package_sh_file" 'REMOVE_EXTENSION'; then
			remove_extension="$REPLY"
		fi
	fi

	if ((${#bins} == 0)); then
		if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
			bins=("$BPM_PACKAGES_PATH/$package"/bin/*)
			bins=("${bins[@]##*/}")
			bins=("${bins[@]/#/bin/}")
		else
			for file in "$BPM_PACKAGES_PATH/$package"/*; do
				if [ -x "$file" ]; then
					local name="${file##*/}"

					if "${remove_extension:-false}"; then
						name="${name%%.*}"
					fi

					rm -f "$BPM_INSTALL_BIN/$name"
				fi
			done

			readarray -t bins < <(find "$BPM_PACKAGES_PATH/$package" -maxdepth 1 -perm -u+x -type f -or -type l)
			bins=("${bins[@]##*/}")
		fi
	fi

	for bin in "${bins[@]}"; do
		local name="${bin##*/}"

		if "${remove_extension:-false}"; then
			name="${name%%.*}"
		fi

		# TODO: unlink?
		rm -f "$BPM_INSTALL_BIN/$name"
	done
}
