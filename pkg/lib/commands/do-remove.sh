# shellcheck shell=bash

do-remove() {
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

	for pkg in "${pkgs[@]}"; do
		util.unappend_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies' "$pkg"
	done


}
