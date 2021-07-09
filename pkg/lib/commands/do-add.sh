# shellcheck shell=bash

do-add() {
	local with_ssh='no'

	local -a pkgs=()
	for arg; do
		case "$arg" in
		--ssh)
			with_ssh='yes'
			;;
		*)
			pkgs+=("$arg")
			;;
		esac
	done

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	fi

	for repoSpec in "${pkgs[@]}"; do
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
