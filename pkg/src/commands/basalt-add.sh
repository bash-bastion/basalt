# shellcheck shell=bash

basalt-add() {
	util.init_local

	local -a pkgs=()
	local arg=
	for arg; do case $arg in
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done; unset -v arg

	if ((${#pkgs[@]} == 0)); then
		print.warn 'No packages were specified'
	fi

	# Package parsing (WET)
	for pkg in "${pkgs[@]}"; do
		if [ "${pkg:0:1}" = '/' ] || [ "${pkg:0:2}" = './' ]; then
			pkg="${pkg%/}"

			# Local packages
			if [ ! -d "$pkg" ]; then # TODO: this is wrong
				print.die "Failed to find package at path '$pkg'"
			fi

			util.toml_add_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "file://$pkg"
		else
			#  Remote packages
			pkgutil.get_package_info "$pkg"
			local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

			if ! util.does_package_exist "$repo_type" "$url"; then
				print.die "Package located at '$url' does not exist"
			fi

			if [ -z "$version" ]; then
				pkgutil.get_latest_package_version "$repo_type" "$url" "$site" "$package"
				version="$REPLY"
			fi

			util.toml_add_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "$url@$version"
		fi
	done

	basalt-install
}
