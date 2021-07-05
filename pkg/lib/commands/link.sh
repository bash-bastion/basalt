# shellcheck shell=bash

resolve_link() {
	if type -p realpath >/dev/null; then
		realpath "$1"
	else
		readlink -f "$1"
	fi
}

basher-link() {
	local no_deps="false"

	case $1 in
		--no-deps)
			no_deps="true"
			shift
		;;
	esac

	if [ "$#" -ne 2 ]; then
		# TODO
		die "Must supply repository and alias"
	fi

	directory="$1"
	package="$2"

	if [ ! -d "$directory" ]; then
		die "Directory '$directory' not found"
	fi

	if [ -z "$package" ]; then
		die "Package must be nonZero"
	fi

	IFS=/ read -r namespace name <<< "$package"

	if [ -z "$namespace" ]; then
		die "Namespace must be nonZero"
		exit 1
	fi

	if [ -z "$name" ]; then
		die "Name must be nonZero"
		exit 1
	fi

	if [ -d "$NEOBASHER_PACKAGES_PATH/$package" ]; then
		die "Package '$package' is already present"
	fi

	# Make sure the namespace directory exists before linking
	if [ ! -d "$NEOBASHER_PACKAGES_PATH/$namespace" ]; then
		mkdir -p "$NEOBASHER_PACKAGES_PATH/$namespace"
	fi

	# Resolve local package path
	directory="$(resolve_link "$directory")"

	ln -s "$directory" "$NEOBASHER_PACKAGES_PATH/$package"

	basher-plumbing-link-bins "$package"
	basher-plumbing-link-completions "$package"
	basher-plumbing-link-completions "$package"

	if [ "$no_deps" = "false" ]; then
		basher-plumbing-deps "$package"
	fi
}
