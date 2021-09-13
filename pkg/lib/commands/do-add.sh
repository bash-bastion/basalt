# shellcheck shell=bash

do-add() {
	util.init_local

	local -a pkgs=()
	for arg; do case "$arg" in
	-*)
		print_simple.die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	for pkg in "${pkgs[@]}"; do
		util.extract_data_from_input "$pkg"
		local repo_uri="$REPLY1"
		local site="$REPLY2"
		local package="$REPLY3"
		local version="$REPLY4"
		local tarball_uri="$REPLY5"

		if [ -z "$version" ]; then
			local latest_tarball_url=
			if ! latest_tarball_url="$(curl -LsS https://api.github.com/repos/hyperupcall/basalt/releases/latest | jq -r '.tarball_url')"; then
				print.die "Could not determine latest release for package '$pkg'"
			fi

			if [ "$latest_tarball_url" = null ]; then
				print.die "Package '$pkg' does not have a release"
			else
				version="${latest_tarball_url##*/}"

				local package_id=
				if [ "$site" = 'github.com' ]; then
					package_id="$package@$version"
				else
					package_id="$site/$package@$version"
				fi

				print.info 'Info' "Add '$package_id' to 'dependencies' in your basalt.toml, then 'basalt install'. Auto-add not yet implemented"
			fi
		fi
	done
}
