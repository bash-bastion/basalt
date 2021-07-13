# shellcheck shell=bash

do-remove() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		# If is local directory
		if [ -d "$repoSpec" ]; then
			local dir=
			dir="$(util.readlink "$repoSpec")"
			dir="${dir%/}"

			util.extract_data_from_package_dir "$dir"
			local site="$REPLY1"
			local package="$REPLY2/$REPLY3"

			if [ "$dir" = "$BPM_PACKAGES_PATH/$site/$package" ]; then
				do_actual_removal "$site/$package"
			fi
		else
			util.extract_data_from_input "$repoSpec"
			local site="$REPLY2"
			local package="$REPLY3"
			local ref="$REPLY4"

			if [ -d "$BPM_PACKAGES_PATH/$site/$package" ]; then
				do_actual_removal "$site/$package"
			elif [ -e "$BPM_PACKAGES_PATH/$site/$package" ]; then
				rm -f "$BPM_PACKAGES_PATH/$site/$package"
			else
				die "Package '$site/$package' is not installed"
			fi
		fi
	done
}

do_actual_removal() {
	local id="$1"

	log.info "Removing '$id'"
	do-plumbing-unlink-man "$id"
	do-plumbing-unlink-bins "$id"
	do-plumbing-unlink-completions "$id"

	printf '%s\n' "  -> Deleting Git repository"
	echo "${BPM_PACKAGES_PATH:?}/$id"
	rm -rf "${BPM_PACKAGES_PATH:?}/$id"
	if ! rmdir -p "${BPM_PACKAGES_PATH:?}/${id%/*}" &>/dev/null; then
		# Do not exit on failure
		:
	fi
}
