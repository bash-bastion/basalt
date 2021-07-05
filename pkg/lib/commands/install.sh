# shellcheck shell=bash

basher-install() {
	local use_ssh="false"

	case "$1" in
		--ssh)
			use_ssh="true"
			shift
		;;
	esac

	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		local site= user= repository= ref=
		util.parse_package_full "$repoSpec"
		IFS=':' read -r site user repository ref <<< "$REPLY"

		log.info "Installing '$repoSpec'"
		basher-plumbing-clone "$use_ssh" "$site" "$user" "$repository" $ref
		basher-plumbing-deps "$user/$repository"
		basher-plumbing-link-bins "$user/$repository"
		basher-plumbing-link-completions "$user/$repository"
		basher-plumbing-link-completions "$user/$repository"
	done
}
