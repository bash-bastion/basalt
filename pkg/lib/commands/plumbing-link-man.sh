# shellcheck shell=bash

basher-plumbing-link-man() {
	local package="$1"

	local files=("$NEOBASHER_PACKAGES_PATH/$package"/man/*)
	files=("${files[@]##*/}")

	local regex="\.([1-9])\$"
	for file in "${files[@]}"; do
		if [[ "$file" =~ $regex ]]; then
			n="${BASH_REMATCH[1]}"
			mkdir -p "$NEOBASHER_INSTALL_MAN/man$n"
			ln -sf "$NEOBASHER_PACKAGES_PATH/$package/man/$file" "$NEOBASHER_INSTALL_MAN/man$n/$file"
		fi
	done
}
