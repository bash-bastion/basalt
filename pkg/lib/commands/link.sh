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
	local package="$2"

	if [ ! -d "$directory" ]; then
		die "Directory '$directory' not found"
	fi

	local site= namespace= repository= ref=
	util.parse_package_full "$2"
	IFS=':' read -r site namespace repository ref <<< "$REPLY"

	local package="$namespace/$repository"

	if [ -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi

	# Make sure the namespace directory exists before linking
	if [ ! -d "$NEOBASHER_PACKAGES_PATH/$namespace" ]; then
		mkdir -p "$NEOBASHER_PACKAGES_PATH/$namespace"
	fi

	# Resolve local package path
	directory="$(util.resolve_link "$directory")"

	ln -s "$directory" "$NEOBASHER_PACKAGES_PATH/$package"

	if [ "$no_deps" = "false" ]; then
		basher-plumbing-deps "$package"
	fi
	basher-plumbing-link-bins "$package"
	basher-plumbing-link-completions "$package"
	basher-plumbing-link-completions "$package"
}
