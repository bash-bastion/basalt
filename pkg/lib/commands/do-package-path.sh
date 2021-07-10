# shellcheck shell=bash

bpm-package-path() {
	local pkg="$1"
	ensure.non_zero 'package' "$pkg"

	printf "%s\n" "$BPM_PACKAGES_PATH/$site/$pkg"
}
