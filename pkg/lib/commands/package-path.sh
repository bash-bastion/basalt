# shellcheck shell=bash

basher-package-path() {
	if [ "$#" -ne 1 ]; then
		die "Must supply package"
	fi

	local package="$1"

	printf "%s" "$NEOBASHER_PACKAGES_PATH/$package"
}
