# shellcheck shell=bash

bpm-plumbing-unlink-man() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	local files=("$BPM_PACKAGES_PATH/$package"/man/*)
	files=("${files[@]##*/}")

	local regex="\.([1-9])\$"
	for file in "${files[@]}"; do
		if [[ "$file" =~ $regex ]]; then
			local n="${BASH_REMATCH[1]}"

			rm -f "$BPM_INSTALL_MAN/man$n/$file"
		fi
	done
}
