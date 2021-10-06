# shellcheck shell=bash

do-global-remove() {
	util.init_global

	local flag_force='no'
	local -a pkgs=()
	for arg; do case "$arg" in
	--force)
		flag_force='yes'
		;;
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	if ((${#pkgs[@]} == 0)); then
		newindent.die "Must specify at least one package"
	fi

	for pkg in "${pkgs[@]}"; do
		util.get_package_info "$pkg"
		local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

		if [ -n "$version" ]; then
			newindent.die "Must not specify ref when removing packages"
		fi

		util.get_package_id --allow-empty-version "$repo_type" "$url" "$site" "$package" "$version"
		local package_id="$REPLY"

		util.text_remove_dependency "$BASALT_GLOBAL_DATA_DIR/global/dependencies" "$url" "$package_id" "$flag_force"
	done

	pkg.do-global-install
}
