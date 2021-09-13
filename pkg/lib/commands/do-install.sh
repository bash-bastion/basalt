# shellcheck shell=bash

do-install() {
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
	util.remove_local_basalt_packages
	pkg.install_package "$BASALT_LOCAL_PROJECT_DIR"
}
