# shellcheck shell=bash

do-link() {
	local install_deps='yes'

	local -a dirs=()
	for arg; do
		case "$arg" in
		--no-deps)
			install_deps='no'
			;;
		*)
			dirs+=("$arg")
			;;
		esac
	done

	if (( ${#dirs[@]} == 0 )); then
		die "You must supply at least one directory"
	fi

	for directory in "${dirs[@]}"; do
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

		# TODO: local git clone
		mkdir -p "$BPM_PACKAGES_PATH/$namespace"
		ln -s "$directory" "$BPM_PACKAGES_PATH/$package"

		log.info "Linking '$directory'"
		if [ "$install_deps" = 'yes' ]; then
			do-plumbing-add-deps "$package"
		fi
		do-plumbing-link-bins "$package"
		do-plumbing-link-completions "$package"
		do-plumbing-link-man "$package"
	done
}
