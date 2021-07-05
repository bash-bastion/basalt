# shellcheck shell=bash

basher-upgrade() {
	local package="$1"

	local site= user= repository= ref=
	util.parse_package_full "$1"
	IFS=':' read -r site user repository ref <<< "$REPLY"

	git -C "$NEOBASHER_PACKAGES_PATH/$user/$repository" pull
}
