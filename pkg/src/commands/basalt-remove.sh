# shellcheck shell=bash

basalt-remove() {
	util.init_local

	local -a pkgs=()
	local arg=
	for arg; do case $arg in
	-*)
		bprint.die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done; unset -v arg

	if ((${#pkgs[@]} == 0)); then
		bprint.warn "No packages were specified"
	fi

	for pkg in "${pkgs[@]}"; do
		util.toml_remove_dependency "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" "$pkg"
	done

	do-install
}
