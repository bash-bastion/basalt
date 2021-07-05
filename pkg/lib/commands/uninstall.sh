# shellcheck shell=bash

basher-uninstall() {
	local package="$1"

	local site= user= repository= ref=
	util.parse_package_full "$1"
	IFS=':' read -r site user repository ref <<< "$REPLY"

	local package="$user/$repository"

	if [ ! -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is not installed"
	fi

	basher-plumbing-unlink-man "$package"
	basher-plumbing-unlink-bins "$package"
	basher-plumbing-unlink-completions "$package"

	rm -rf "${NEOBASHER_PACKAGES_PATH:?}/$package"
}
