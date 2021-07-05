# shellcheck shell=bash

basher-list() {
	util.show_help_if_flag_passed 'list' "$@"

	local username= package=
	for package_path in "$BASHER_PACKAGES_PATH"/*/*; do
		username="${package_path%/*}"; username="${username##*/}"
		package="${package_path##*/}"
		printf "%s\n" "$username/$package"
	done
}
