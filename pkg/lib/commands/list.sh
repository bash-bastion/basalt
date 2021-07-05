# shellcheck shell=bash

basher-list() {
	local shouldShowOutdated=false

	for arg; do
		if [ "$arg" == --outdated ]; then
			shouldShowOutdated=true
			shift
		fi
	done

	if [ "$shouldShowOutdated" = true ]; then
		readarray -t packages < <(basher-list)

		for package in "${packages[@]}"; do
			package_path="$NEOBASHER_PACKAGES_PATH/$package"
			if [ ! -L "$package_path" ]; then
				ensure.cd "$package_path"
				git remote update > /dev/null 2>&1
				if git symbolic-ref --short -q HEAD > /dev/null; then
						if [ "$(git rev-list --count HEAD...HEAD@{upstream})" -gt 0 ]; then
							echo "$package"
						fi
				fi
			fi
		done
	else
		local username= package=
		for package_path in "$NEOBASHER_PACKAGES_PATH"/*/*; do
			username="${package_path%/*}"; username="${username##*/}"
			package="${package_path##*/}"
			printf "%s\n" "$username/$package"
		done
	fi
}
