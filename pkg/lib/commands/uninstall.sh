# shellcheck shell=bash

basher-uninstall() {
	if [ "$#" -ne 1 ]; then
		die "Must supply package to uninstall"
	fi

	package="$1"

	if [ -z "$package" ]; then
		die "Package must be nonZero"
	fi

	IFS=/ read -r user name <<< "$package"

	if [ -z "$user" ]; then
		die "User must be nonZero"
	fi

	if [ -z "$name" ]; then
		die "Name must be nonZero"
	fi

	if [ ! -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is not installed"
	fi

	basher-plumbing-unlink-man "$package"
	basher-plumbing-unlink-bins "$package"
	basher-plumbing-unlink-completions "$package"

	rm -rf "${NEOBASHER_PACKAGES_PATH:?}/$package"
}
