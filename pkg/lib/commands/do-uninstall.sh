# shellcheck shell=bash

do-uninstall() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		local package="$user/$repository"

		if [ ! -e "$BPM_PACKAGES_PATH/$package" ]; then
			die "Package '$package' is not installed"
		fi

		log.info "Uninstalling '$repoSpec'"
		do-plumbing-unlink-man "$package"
		do-plumbing-unlink-bins "$package"
		do-plumbing-unlink-completions "$package"

		rm -rf "${BPM_PACKAGES_PATH:?}/$package"
	done
}
