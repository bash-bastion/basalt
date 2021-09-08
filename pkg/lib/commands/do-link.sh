# shellcheck shell=bash

do-link() {
	util.init_command

	local -a dirs=()
	for arg; do
		case "$arg" in
		-*)
			die "Flag '$arg' not recognized"
			;;
		*)
			dirs+=("$arg")
			;;
		esac
	done

	if (( ${#dirs[@]} == 0 )); then
		die 'At least one package must be supplied'
	fi

	for dir in "${dirs[@]}"; do
		if [ ! -d "$dir" ]; then
			die "Directory '$dir' not found"
		fi

		dir="$(util.readlink "$dir")"
		dir="${dir%/}"

		if [ ! -d "$dir/.git" ]; then
			die "Package must be a Git repository"
		fi

		local user="local"
		local repository="${dir##*/}"
		local package="$user/$repository"

		if [ -e "$BPM_PACKAGES_PATH/$package" ]; then
			die "Package '$package' is already present"
		fi

		mkdir -p "$BPM_PACKAGES_PATH/$user"
		ln -s "$dir" "$BPM_PACKAGES_PATH/$package"

		log.info "Symlinking '$dir'"
		plumbing.symlink-bins "$package"
		plumbing.symlink-completions "$package"
		plumbing.symlink-mans "$package"
	done
}
