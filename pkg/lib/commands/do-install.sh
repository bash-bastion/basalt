# shellcheck shell=bash

do-install() {
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

	# Everything in the local ./basalt_packages is a symlink to some file or directory
	# stored globally (per-user). Thus, we can just remove it since it won't take long
	# to re-symlink. Additionally, this will provide auto package pruning
	if ! rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"; then
		print.die "Could not remove local 'basalt_packages' directory"
	fi

	pkg.install_package "$BASALT_LOCAL_PROJECT_DIR"
}
