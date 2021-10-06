# shellcheck shell=bash

do-global-install() {
	util.init_global

	if (($# != 0)); then
		newindent.die "No arguments or flags must be specified"
	fi

	# TODO: this should be changed when we make global location dot_basalt
	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/.basalt"; then
		print.indent-die "Could not remove global '.basalt' directory"
	fi

	local -a deps=()
	local dep=
	while IFS= read -r dep; do
		if [ -z "$dep" ]; then
			continue
		fi

		deps+=("$dep")
	done < "$BASALT_GLOBAL_DATA_DIR/global/dependencies"; unset dep

	pkg.install_package "$BASALT_GLOBAL_DATA_DIR/global" 'lenient' "${deps[@]}"
}
