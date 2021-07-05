# shellcheck shell=bash

basher-plumbing-unlink-bins() {
	local package="$1"

	local bins
	if [ -e "$NEOBASHER_PACKAGES_PATH/$package/package.sh" ]; then
		source "$NEOBASHER_PACKAGES_PATH/$package/package.sh"
		IFS=: read -ra bins <<< "$BINS"
	fi

	if [ -z "$bins" ]; then
		if [ -e "$NEOBASHER_PACKAGES_PATH/$package/bin" ]; then
			bins=($NEOBASHER_PACKAGES_PATH/$package/bin/*)
			bins=("${bins[@]##*/}")
			bins=("${bins[@]/#/bin/}")
		else
			bins=($(find "$NEOBASHER_PACKAGES_PATH/$package" -maxdepth 1 -perm -u+x -type f -or -type l))
			bins=("${bins[@]##*/}")
		fi
	fi

	for bin in "${bins[@]}"; do
		local name="${bin##*/}"
		if ${REMOVE_EXTENSION:-false}; then
			name="${name%%.*}"
		fi
		rm -f "$NEOBASHER_INSTALL_BIN/$name"
	done
}
