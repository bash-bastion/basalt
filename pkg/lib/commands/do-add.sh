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
		util.get_package_info "$pkg"
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		if [ -z "$version" ]; then
			util.get_latest_package_version "$repo_type" "$url" "$site" "$package"
			version="$REPLY"
		fi

		# Don't use 'util.get_package_id' here
		local package_str=
		if [ "$repo_type" = 'remote' ]; then
			package_str="$site/$package@$version"
			package_str="${package_str#github.com/}"
		elif [ "$repo_type" = 'local' ]; then
			package_str="$url@$version"
		fi

		util.append_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies' "$package_str"
	done

	do-install
}
