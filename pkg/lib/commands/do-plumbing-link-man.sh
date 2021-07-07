# shellcheck shell=bash

# TODO: cleanup
bpm-plumbing-link-man() {
	local package="$1"
	ensure.nonZero 'package' "$package"

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
