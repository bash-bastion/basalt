# shellcheck shell=bash

do-install() {
	local with_ssh='no'

	case "$1" in
		--ssh)
			with_ssh='yes'
			shift
		;;
	esac

	if (( $# == 0 )); then
		die "At least one package must be supplied"
	fi

	for repoSpec; do
		util.construct_clone_url "$repoSpec" "$with_ssh"
		local uri="$REPLY1"
		local package="$REPLY2"
		local ref="$REPLY3"

		log.info "Installing '$repoSpec'"
		do-plumbing-clone "$uri" "$package" $ref
		do-plumbing-add-deps "$package"
		do-plumbing-link-bins "$package"
		do-plumbing-link-completions "$package"
		do-plumbing-link-man "$package"
	done
}
