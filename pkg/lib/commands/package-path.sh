# shellcheck shell=bash

basher-package-path() {
	if [ "$#" -ne 1 ]; then
		basher-help package-path
		exit 1
	fi

	local package="$1"

	printf "%s" "$BASHER_PACKAGES_PATH/$package"
}
