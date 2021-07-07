# shellcheck shell=bash

do-install() {
	local use_ssh="false"

	case "$1" in
		--ssh)
			use_ssh="true"
			shift
		;;
	esac

	if (( $# == 0 )); then
		die "At least one package must be supplied"
	fi

	for repoSpec; do
		local site= user= repository= ref=

		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		log.info "Installing '$repoSpec'"
		do-plumbing-clone "$use_ssh" "$site" "$user" "$repository" $ref
		do-plumbing-deps "$user/$repository"
		do-plumbing-link-bins "$user/$repository"
		do-plumbing-link-completions "$user/$repository"
		do-plumbing-link-man "$user/$repository"
	done
}
