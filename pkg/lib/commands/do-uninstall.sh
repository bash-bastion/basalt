# shellcheck shell=bash

do-uninstall() {
	if (( $# == 0 )); then
		die "You must supply at least one package"
	fi

	for repoSpec; do
		if [ -d "$repoSpec" ]; then
			local fullPath=
			fullPath="$(util.readlink "$repoSpec")"
			fullPath="${fullPath%/}"

			local user="${fullPath%/*}"; user="${user##*/}"
			local repository="${fullPath##*/}"
			if [ "$fullPath" == "$BPM_PACKAGES_PATH/$user/$repository" ]; then
				do_actual_uninstall "$user/$repository"
			fi
		else
			local site= user= repository= ref=
			util.parse_package_full "$repoSpec"
			IFS=':' read -r site user repository ref <<< "$REPLY"

			if [ -d "$BPM_PACKAGES_PATH/$user/$repository" ]; then
				do_actual_uninstall "$user/$repository"
			elif [ -f "$BPM_PACKAGES_PATH/$user/$repository" ]; then
				rm -f "$BPM_PACKAGES_PATH/$user/$repository"
			else
				die "Package '$user/$repository' is not installed"
			fi
		fi
	done
}

do_actual_uninstall() {
	local package="$1"

	log.info "Uninstalling '$package'"
	do-plumbing-unlink-man "$package"
	do-plumbing-unlink-bins "$package"
	do-plumbing-unlink-completions "$package"

	rm -rf "${BPM_PACKAGES_PATH:?}/$package"
}
