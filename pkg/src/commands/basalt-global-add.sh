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
		print.die 'Must specify at least one package'
	fi

	for pkg in "${pkgs[@]}"; do
		pkgutil.get_allinfo "$pkg"
		local _pkg_type="$REPLY1"
		local _pkg_rawtext="$REPLY2"
		local _pkg_location="$REPLY3"
		local _pkg_fqlocation="$REPLY4"
		local _pkg_fsslug="$REPLY5"
		local _pkg_site="$REPLY6"
		local _pkg_fullname="$REPLY7"
		local _pkg_version="$REPLY8"

		if ! util.does_package_exist "$_pkg_type" "$_pkg_location"; then
			print.die "Package located at '$_pkg_location' does not exist"
		fi

		if [ -z "$_pkg_version" ]; then
			pkgutil.get_latest_package_version "$_pkg_type" "$_pkg_location" "$_pkg_site" "$_pkg_fullname"
			_pkg_version="$REPLY"
		fi

		util.text_add_dependency "$BASALT_GLOBAL_DATA_DIR/global/dependencies" "$_pkg_location@$_pkg_version"
	done

	basalt-global-install
}
