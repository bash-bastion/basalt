# shellcheck shell=bash

bpm-package-path() {
	local id="$1"
	ensure.non_zero 'id' "$id"

	util.extract_data_from_input "$id"
	local site="$REPLY2"
	local package="$REPLY3"
	local ref="$REPLY4"

	printf "%s\n" "$BPM_PACKAGES_PATH/$site/$package"
}
