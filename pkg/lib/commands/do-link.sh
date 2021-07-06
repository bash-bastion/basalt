# shellcheck shell=bash

bpm-link() {
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

	directory="$(util.resolve_link "$directory")"


	local namespace="bpm-local"
	local repository="${directory##*/}"
	local package="$namespace/$repository"

	if [ -d "$BPM_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi


	mkdir -p "$BPM_PACKAGES_PATH/$namespace"
	ln -s "$directory" "$BPM_PACKAGES_PATH/$package"

	if [ "$no_deps" = "false" ]; then
		bpm-plumbing-deps "$package"
	fi
	bpm-plumbing-link-bins "$package"
	bpm-plumbing-link-completions "$package"
	bpm-plumbing-link-completions "$package"
}
