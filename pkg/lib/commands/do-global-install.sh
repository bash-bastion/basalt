# shellcheck shell=bash

do-global-install() {
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

	local bpm_toml_file="$BPM_LOCAL_PROJECT_DIR/bpm.toml"
	if util.get_toml_array "$bpm_toml_file" 'dependencies'; then
		log.info "Adding all dependencies"

		for pkg in "${REPLIES[@]}"; do
			do-actual-add "$pkg" "$flag_branch"
		done
	else
		log.warn "No dependencies specified in 'dependencies' key"
	fi
}
