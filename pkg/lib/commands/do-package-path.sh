# shellcheck shell=bash

bpm-package-path() {
	local id="$1"

	if [ -z "$id" ]; then
		die "No package specified"
	fi

	util.setup_mode

	util.extract_data_from_input "$id"
	local site="$REPLY2"
	local package="$REPLY3"
	local ref="$REPLY4"

	local dir="$BPM_PACKAGES_PATH/$site/$package"
	if [ -d "$dir" ]; then
		printf "%s\n" "$dir"
	else
		die "Package '$site/$package' is not installed"
	fi
}
