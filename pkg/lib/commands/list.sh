# shellcheck shell=bash

basher-list() {
	local username= package=
	for package_path in "$NEOBASHER_PACKAGES_PATH"/*/*; do
		username="${package_path%/*}"; username="${username##*/}"
		package="${package_path##*/}"
		printf "%s\n" "$username/$package"
	done
}
