# shellcheck shell=bash

do-upgrade() {
	local upgrade_bpm='no'

	local -a pkgs=()
	for arg; do
		case "$arg" in
		bpm)
			upgrade_bpm='yes'
			;;
		*)
			pkgs+=("$arg")
			;;
		esac
	done

	if [ "$upgrade_bpm" = 'yes' ]; then
		if (( ${#pkgs[@]} > 0 )); then
			die 'You cannot upgarde bpm and its packages at the same time'
		fi

		if [ -d "$PROGRAM_LIB_DIR/../../.git" ]; then
			git -C "$PROGRAM_LIB_DIR/../.." pull
		else
			log.error "bpm is not a Git repository"
		fi

		return
	fi

	if (( ${#pkgs[@]} == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		util.construct_clone_url "$repoSpec"
		local uri="$REPLY1"
		local site="$REPLY2"
		local package="$REPLY3"
		local ref="$REPLY4"

		log.info "Upgrading '$repoSpec'"
		do-plumbing-remove-deps "$site/$package"
		do-plumbing-unlink-bins "$site/$package"
		do-plumbing-unlink-completions "$site/$package"
		do-plumbing-unlink-man "$site/$package"
		git -C "$BPM_PACKAGES_PATH/$site/$package" pull
		do-plumbing-add-deps "$site/$package"
		do-plumbing-link-bins "$site/$package"
		do-plumbing-link-completions "$site/$package"
		do-plumbing-link-man "$site/$package"
	done
}
