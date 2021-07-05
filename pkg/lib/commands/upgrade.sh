#!/usr/bin/env bash


basher-upgrade() {
	if [ "$#" -ne 1 ]; then
		die "Must supply arguments"
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

	ensure.cd "$BASHER_PACKAGES_PATH/$package"
	git pull
}
