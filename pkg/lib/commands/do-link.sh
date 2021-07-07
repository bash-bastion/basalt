# shellcheck shell=bash

do-link() {
	local no_deps="false"

	case $1 in
		--no-deps)
			no_deps="true"
			shift
		;;
	esac

	local directory="$1"

	if [ ! -d "$directory" ]; then
		die "Directory '$directory' not found"
	fi

	directory="$(util.readlink "$directory")"

	local namespace="bpm-local"
	local repository="${directory##*/}"
	local package="$namespace/$repository"

	if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi

	mkdir -p "$BPM_PACKAGES_PATH/$namespace"
	ln -s "$directory" "$BPM_PACKAGES_PATH/$package"

	log.info "Linking '$directory'"
	if [ "$no_deps" = "false" ]; then
		do-plumbing-deps "$package"
	fi
	do-plumbing-link-bins "$package"
	do-plumbing-link-completions "$package"
	do-plumbing-link-man "$package"
}
