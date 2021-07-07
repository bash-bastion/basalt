# shellcheck shell=bash

bpm-package-path() {
	local package="$1"
	ensure.nonZero 'package' "$package"

	printf "%s\n" "$BPM_PACKAGES_PATH/$package"
}
