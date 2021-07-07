# shellcheck shell=bash

bpm-plumbing-link-bins() {
	local package="$1"

	ensure.nonZero 'package' "$package"

	local REMOVE_EXTENSION=
	local -a bins=()

	local packageShFile="$BPM_PACKAGES_PATH/$package/package.sh"
	if [ -f "$packageShFile" ]; then
		util.extract_shell_variable "$packageShFile" 'BINS'
		IFS=':' read -ra bins <<< "$REPLY"

		util.extract_shell_variable "$packageShFile" 'REMOVE_EXTENSION'
		REMOVE_EXTENSION="$REPLY"
	fi

	# Either get bins from a 'bin' folder, or directly from the repository
	if ((${#bins} == 0)); then
		if [ -d "$BPM_PACKAGES_PATH/$package/bin" ]; then
			bins=("$BPM_PACKAGES_PATH/$package"/bin/*)
			bins=("${bins[@]##*/}")
			bins=("${bins[@]/#/bin/}")
		else
			readarray -t bins < <(find "$BPM_PACKAGES_PATH/$package" -maxdepth 1 -mindepth 1 -perm -u+x -type f -or -type l)
			bins=("${bins[@]##*/}")
		fi
	fi


	for bin in "${bins[@]}"; do
		local name="${bin##*/}"

		if "${REMOVE_EXTENSION:-false}"; then
			name="${name%%.*}"
		fi

		mkdir -p "$BPM_INSTALL_BIN"
		ln -sf "$BPM_PACKAGES_PATH/$package/$bin" "$BPM_INSTALL_BIN/$name"
		chmod +x "$BPM_INSTALL_BIN/$name"
	done

}
