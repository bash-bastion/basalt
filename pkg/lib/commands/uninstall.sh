# shellcheck shell=bash

basher-uninstall() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		log.info "Uninstalling '$repoSpec'"

		local package="$user/$repository"

		if [ ! -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
			die "Package '$package' is not installed"
		fi

		basher-plumbing-unlink-man "$package"
		basher-plumbing-unlink-bins "$package"
		basher-plumbing-unlink-completions "$package"

		rm -rf "${NEOBASHER_PACKAGES_PATH:?}/$package"
	done
}
