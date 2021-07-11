# shellcheck shell=bash

bpm-package-path() {
	local id="$1"
	ensure.non_zero 'id' "$id"

	util.extract_data_from_input "$id"
	local site="$REPLY2"
	local package="$REPLY3"
	local ref="$REPLY4"

	local dir="$BPM_PACKAGES_PATH/$site/$package"
	if [ -d "$dir" ]; then
		printf "%s\n" "$dir"
	else
		die "Package '$site/$package' not found"
	fi
}
