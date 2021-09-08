# shellcheck shell=bash

do-install() {
	util.init_command

	local -a pkgs=()
	for arg; do case "$arg" in
	-*)
		die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	local basalt_toml_file="$BASALT_LOCAL_PROJECT_DIR/basalt.toml"
	if util.get_toml_array "$basalt_toml_file" 'dependencies'; then
		for pkg in "${REPLIES[@]}"; do
			util.extract_data_from_input "$pkg"
			local uri="$REPLY1"
			local site="$REPLY2"
			local package="$REPLY3"
			local version="$REPLY4"

			pkg.download_package_tarball "$site" "$package" "$version"
			pkg.extract_package_tarball "$site" "$package" "$version"
			pkg.do_strict_symlink "$site" "$package" "$version"
		done
	else
		log.warn "No dependencies specified in 'dependencies' key"
	fi
}
