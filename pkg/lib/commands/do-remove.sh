# shellcheck shell=bash

do-remove() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		# If is local directory
		# TODO: do this for upgrade as well
		if [ -d "$repoSpec" ]; then
			local fullPath=
			fullPath="$(util.readlink "$repoSpec")"
			fullPath="${fullPath%/}"

			# TODO: make this a funcion, share it with do-list
			local site="${fullPath%/*}"; site="${site%/*}"; site="${site##*/}"
			local user="${fullPath%/*}"; user="${user##*/}"
			local repository="${fullPath##*/}"
			local package="$user/$repository"

			if [ "$fullPath" = "$BPM_PACKAGES_PATH/$site/$package" ]; then
				do_actual_removal "$site/$package"
			fi
		else
			util.construct_clone_url "$repoSpec"
			local uri="$REPLY1"
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

	log.info "Uninstalling '$id'"
	do-plumbing-unlink-man "$id"
	do-plumbing-unlink-bins "$id"
	do-plumbing-unlink-completions "$id"

	rm -rf "${BPM_PACKAGES_PATH:?}/$id"
	if ! rmdir -p "${BPM_PACKAGES_PATH:?}/$id"; then
		# Do not exit on failure
		:
	fi
}
