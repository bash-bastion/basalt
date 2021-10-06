# shellcheck shell=bash

do-global-install() {
	util.init_global

	if (($# != 0)); then
		newindent.die "No arguments or flags must be specified"
	fi

	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/.basalt"; then
		print.indent-die "Could not remove global '.basalt' directory"
	fi

	local -a dependencies=()
	local dep=
	while IFS= read -r dep; do
		if [ -z "$dep" ]; then
			continue
		fi

		dependencies+=("$dep")
	done < "$BASALT_GLOBAL_DATA_DIR/global/dependencies"; unset dep

	pkg.install_package "$BASALT_GLOBAL_DATA_DIR/global" 'lenient' "${dependencies[@]}"
	pkg.phase_local_integration_recursive "$BASALT_GLOBAL_DATA_DIR/global" 'yes' 'strict' "${dependencies[@]}"
	pkg.phase_local_integration_nonrecursive "$BASALT_GLOBAL_DATA_DIR/global"
}
