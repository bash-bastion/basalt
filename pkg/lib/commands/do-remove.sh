# shellcheck shell=bash

do-remove() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		util.extract_data_from_input "$repoSpec"
		local site="$REPLY2"
		local package="$REPLY3"

		if [ -d "$BPM_PACKAGES_PATH/$site/$package" ]; then
			do_actual_removal "$site/$package"
		elif [ -e "$BPM_PACKAGES_PATH/$site/$package" ]; then
			rm -f "$BPM_PACKAGES_PATH/$site/$package"
		else
			die "Package '$site/$package' is not installed"
		fi
	done
}

do_actual_removal() {
	local id="$1"

	log.info "Removing '$id'"
	do-plumbing-unlink-man "$id"
	do-plumbing-unlink-bins "$id"
	do-plumbing-unlink-completions "$id"

	if [ "${id%%/*}" = 'local' ]; then
		printf '%s\n' "  -> Unsymlinking directory"
		unlink "$BPM_PACKAGES_PATH/$id"
	else
		printf '%s\n' "  -> Deleting Git repository"
		rm -rf "${BPM_PACKAGES_PATH:?}/$id"
		if ! rmdir -p "${BPM_PACKAGES_PATH:?}/${id%/*}" &>/dev/null; then
			# Do not exit on "failure"
			:
		fi
	fi

}
