# shellcheck shell=bash

bpm-plumbing-link-man() {
	local package="$1"

	local files=("$BPM_PACKAGES_PATH/$package"/man/*)
	files=("${files[@]##*/}")

	local regex="\.([1-9])\$"
	for file in "${files[@]}"; do
		if [[ "$file" =~ $regex ]]; then
			local n="${BASH_REMATCH[1]}"
			mkdir -p "$BPM_INSTALL_MAN/man$n"
			ln -sf "$BPM_PACKAGES_PATH/$package/man/$file" "$BPM_INSTALL_MAN/man$n/$file"
		fi
	done
}
