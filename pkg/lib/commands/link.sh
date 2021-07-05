# shellcheck shell=bash

basher-link() {
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


	local namespace="neobasher-local"
	local repository="${directory##*/}"
	local package="$namespace/$repository"

	if [ -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi


	mkdir -p "$NEOBASHER_PACKAGES_PATH/$namespace"
	ln -s "$directory" "$NEOBASHER_PACKAGES_PATH/$package"

	if [ "$no_deps" = "false" ]; then
		basher-plumbing-deps "$package"
	fi
	basher-plumbing-link-bins "$package"
	basher-plumbing-link-completions "$package"
	basher-plumbing-link-completions "$package"
}
