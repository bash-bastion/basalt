# shellcheck shell=bash

do-remove() {
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
		util.toml_remove_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "$pkg"
	done

	do-install
}
