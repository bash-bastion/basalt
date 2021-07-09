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
