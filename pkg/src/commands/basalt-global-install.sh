# shellcheck shell=bash

basalt-global-install() {
	util.init_global

	if (($# != 0)); then
		print.die "No arguments or flags must be specified. Did you mean 'basalt global add'?"
	fi

	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/.basalt"; then
		print.die "Could not remove global '.basalt' directory"
	fi

	local -a dependencies=()
	local dep=
	while IFS= read -r dep; do
		if [ -z "$dep" ]; then
			continue
		fi

		dependencies+=("$dep")
	done < "$BASALT_GLOBAL_DATA_DIR/global/dependencies"; unset dep

	pkg.list_packages "$BASALT_GLOBAL_DATA_DIR/global" "${dependencies[@]}"
	pkg.install_packages "$BASALT_GLOBAL_DATA_DIR/global" 'lenient' "${dependencies[@]}"
	pkg.phase_local_integration_recursive "$BASALT_GLOBAL_DATA_DIR/global" 'yes' 'lenient' "${dependencies[@]}"
	pkg.phase_local_integration_nonrecursive "$BASALT_GLOBAL_DATA_DIR/global"
}
