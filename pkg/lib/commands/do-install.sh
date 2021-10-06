# shellcheck shell=bash

do-install() {
	util.init_local

	if (($# != 0)); then
		newindent.die "No arguments or flags must be specified"
	fi

	if ! rm -rf "$BASALT_LOCAL_PROJECT_DIR/.basalt"; then
		print.die "Could not remove local '.basalt' directory"
	fi

	# 'basalt.toml' is guaranteed to exist due to 'util.init_local'
	if util.get_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'dependencies'; then
		pkg.install_package "$BASALT_LOCAL_PROJECT_DIR" 'strict' "${REPLIES[@]}"
	fi
}
