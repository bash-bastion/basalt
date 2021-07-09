# shellcheck shell=bash

do-upgrade() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"
		local package="$user/$repository"

		log.info "Upgrading '$repoSpec'"
		do-plumbing-remove-deps "$package"
		do-plumbing-unlink-bins "$package"
		do-plumbing-unlink-completions "$package"
		do-plumbing-unlink-man "$package"
		git -C "$BPM_PACKAGES_PATH/$user/$repository" pull
		do-plumbing-add-deps "$package"
		do-plumbing-link-bins "$package"
		do-plumbing-link-completions "$package"
		do-plumbing-link-man "$package"
	done
}
