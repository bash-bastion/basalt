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
		local repo_uri="$REPLY1"
		local site="$REPLY2"
		local package="$REPLY3"
		local version="$REPLY4"

		if [ -z "$version" ]; then
			util.get_latest_package_version "$repo_uri" "$site" "$package"
			version="$REPLY"
		fi

		if [ "${repo_uri::7}" = 'file://' ]; then
			package_str="$repo_uri@$version"
		else
			package_str="$site/$package@$version"
			package_str="${package_str#github.com/}"
		fi

		util.append_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies' "$package_str"
		do-install
	done
}
