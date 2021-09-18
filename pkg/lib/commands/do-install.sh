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

	# Everything in the local ./basalt_packages is a symlink to something in the global
	# cellar directory. Thus, we can just remove it since it won't take long to re-symlink.
	# This has the added benefit that outdated packages will automatically be pruned
	if ! rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"; then
		print_simple.die "Could not remove local 'basalt_packages' directory"
	fi
	pkg.install_package "$BASALT_LOCAL_PROJECT_DIR"
}
