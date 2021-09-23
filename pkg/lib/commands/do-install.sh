# shellcheck shell=bash

do-install() {
	util.init_local

	for arg; do case "$arg" in
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	esac done

	# Everything in the local ./basalt_packages is a symlink to some file or directory
	# stored globally (per-user). Thus, we can just remove it since it won't take long
	# to re-symlink. Additionally, this will provide auto package pruning
	if ! rm -rf "$BASALT_LOCAL_PROJECT_DIR/basalt_packages"; then
		print.die "Could not remove local 'basalt_packages' directory"
	fi

	# 'basalt.toml' is guaranteed to exist due to 'util.init_local'
	if util.get_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies'; then
		pkg.install_package "$BASALT_LOCAL_PROJECT_DIR" "${REPLIES[@]}"
	fi
}
