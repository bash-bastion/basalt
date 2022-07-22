# shellcheck shell=bash

basalt-global-remove() {
	util.init_global

	local flag_force='no'
	local -a pkgs=()
	local arg=
	for arg; do case $arg in
	--force)
		flag_force='yes'
		;;
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
		pkgutil.get_package_info "$pkg"
		local url="$REPLY2" version="$REPLY5"

		if [ -n "$version" ]; then
			print.die "Must not specify ref when removing packages"
		fi

		util.text_remove_dependency "$BASALT_GLOBAL_DATA_DIR/global/dependencies" "$url" "$flag_force"
	done

	basalt-global-install
}
