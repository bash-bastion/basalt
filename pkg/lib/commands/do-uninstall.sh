# shellcheck shell=bash

bpm-uninstall() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		log.info "Uninstalling '$repoSpec'"

		local package="$user/$repository"

		if [ ! -d "$BPM_PACKAGES_PATH/$package" ]; then
			die "Package '$package' is not installed"
		fi

		bpm-plumbing-unlink-man "$package"
		bpm-plumbing-unlink-bins "$package"
		bpm-plumbing-unlink-completions "$package"

		rm -rf "${BPM_PACKAGES_PATH:?}/$package"
	done
}
