# shellcheck shell=bash

basalt-global-add() {
	util.init_global

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
		print.die "Must specify at least one package"
	fi

	for pkg in "${pkgs[@]}"; do
		util.get_package_info "$pkg"
		local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

		if ! util.does_package_exist "$repo_type" "$url"; then
			print.die "Package located at '$url' does not exist"
		fi

		if [ -z "$version" ]; then
			util.get_latest_package_version "$repo_type" "$url" "$site" "$package"
			version="$REPLY"
		fi

		util.text_add_dependency "$BASALT_GLOBAL_DATA_DIR/global/dependencies" "$url@$version"
	done

	basalt-global-install
}
