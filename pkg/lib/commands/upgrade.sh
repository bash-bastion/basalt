# shellcheck shell=bash

basher-upgrade() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		log.info "Upgrading '$repoSpec'"

		git -C "$NEOBASHER_PACKAGES_PATH/$user/$repository" pull
	done
}
