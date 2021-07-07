# shellcheck shell=bash

bpm-install() {
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
		bpm-plumbing-clone "$use_ssh" "$site" "$user" "$repository" $ref
		bpm-plumbing-deps "$user/$repository"
		bpm-plumbing-link-bins "$user/$repository"
		bpm-plumbing-link-completions "$user/$repository"
		bpm-plumbing-link-man "$user/$repository"
	done
}
