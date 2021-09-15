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
			util.get_latest_package_version "$package"
			package_str="$REPLY"
		fi

		util.append_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies' "$package_str"
		do-install
	done
}
