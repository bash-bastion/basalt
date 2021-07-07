# shellcheck shell=bash

bpm-list() {
	local shouldShowOutdated=false

	for arg; do
		case "$arg" in
		--outdated)
			shouldShowOutdated=true
			shift
			;;
		esac
	done

	if [ "$shouldShowOutdated" = true ]; then
		local packages
		readarray -t packages < <(bpm-list)

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
		for package_path in "$BPM_PACKAGES_PATH"/*/*; do
			local user="${package_path%/*}"; user="${user##*/}"
			local repository="${package_path##*/}"
			printf "%s\n" "$user/$repository"
		done
	fi
}
