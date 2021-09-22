# shellcheck shell=bash

do-add() {
	util.init_local

	local -a pkgs=()
	for arg; do case "$arg" in
	-*)
		print.die "Flag '$arg' not recognized"
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

		util.toml_add_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "$url@$version"
	done

	do-install
}
