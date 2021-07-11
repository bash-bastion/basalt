# shellcheck shell=bash

do-list() {
	local should_show_outdated='no'

	for arg; do
		case "$arg" in
		--outdated)
			should_show_outdated='yes'
			;;
		esac
	done

	local has_invalid_packages='no'

	if [ "$should_show_outdated" = 'yes' ]; then
		local packages
		readarray -t packages < <(do-list)

		for package in "${packages[@]}"; do
			local package_path="$BPM_PACKAGES_PATH/$package"

			if [ ! -L "$package_path" ]; then
				ensure.cd "$package_path"
				git remote update &>/dev/null

				if git symbolic-ref --short -q HEAD >/dev/null; then
					# shellcheck disable=SC1083
					if [ "$(git rev-list --count HEAD...HEAD@{upstream})" -gt 0 ]; then
						printf "%s\n" "$package"
					fi
				fi
			fi
		done
	else
		for package_path in "$BPM_PACKAGES_PATH"/*/*/*; do
			util.extract_data_from_package_dir "$package_path"
			local site="$REPLY1"
			local user="$REPLY2"
			local repository="$REPLY3"
			local package="$user/$repository"

			# Users that have installed packages before the switch to namespacing by
			# site domain name will print incorrectly. So, we check to make sure the site
			# url is actually is a domain name and not, for example, a GitHub username
			if [[ "$site" != *.* ]] && [ "$site" != 'local' ]; then
				has_invalid_packages='yes'
				continue
			fi

			if [ "$site" = 'local' ]; then
				printf "%s\n" "$site/$user"
			else
				printf "%s\n" "$site/$package"
			fi
		done
	fi

	if [ "$has_invalid_packages" = 'yes' ]; then
		log.error "You have invalid packages. To fix this optimally, remove the '${BPM_PACKAGES_PATH%/*}' directory and reinstall all that packages that were deleted in the process"
	fi
}
