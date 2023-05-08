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

	# Package parsing
	for pkg in "${pkgs[@]}"; do
		if [ "${pkg:0:1}" = '/' ] || [ "${pkg:0:2}" = './' ]; then
			pkg="${pkg%/}"

			# Local packages
			if [ ! -d "$pkg" ]; then # TODO: this is wrong
				print.die "Failed to find package at path '$pkg'"
			fi

			util.toml_add_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "file://$pkg"
		else
			pkgutil.get_allinfo "$pkg"
			local _pkg_type="$REPLY1"
			local _pkg_rawtext="$REPLY2"
			local _pkg_location="$REPLY3"
			local _pkg_fqlocation="$REPLY4"
			local _pkg_fsslug="$REPLY5"
			local _pkg_site="$REPLY6"
			local _pkg_fullname="$REPLY7"
			local _pkg_version="$REPLY8"

			# Remote packages
			if ! util.does_package_exist "$_pkg_type" "$_pkg_fqlocation"; then
				print.die "Package located at '$_pkg_fqlocation' does not exist"
			fi

			if [ -z "$_pkg_version" ]; then
				pkgutil.get_latest_package_version "$_pkg_type" "$_pkg_fqlocation" "$_pkg_site" "$_pkg_fullname"
				_pkg_version="$REPLY"
			fi

			util.toml_add_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "$_pkg_fqlocation@$_pkg_version"
		fi
	done

	basalt-install
}
