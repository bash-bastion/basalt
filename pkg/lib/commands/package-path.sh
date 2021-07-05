# shellcheck shell=bash

basher-package-path() {
	local package="$1"

	ensure.nonZero 'package' "$package"

	printf "%s\n" "$NEOBASHER_PACKAGES_PATH/$package"
}
