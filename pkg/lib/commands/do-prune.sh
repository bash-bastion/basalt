# shellcheck shell=bash

# TODO: prune local packages that are no longer in dependencies
do-prune() {
	util.setup_mode

	log.info "Pruning packages"

	for file in "$BPM_INSTALL_BIN"/* "$BPM_INSTALL_MAN"/*/* "$BPM_INSTALL_COMPLETIONS"/{bash,zsh/{compsys,compctl},fish}/*; do
		local real_file=
		real_file="$(readlink "$file")"

		if [[ "${real_file:0:1}" == / && -e "$real_file" ]]; then
			# The only valid symlinks 'bpm' creates are absolute paths
			# to an existing file
			continue
		fi

		printf '  -> %s\n' "Unsymlinking broken symlink '$file'"
		unlink "$file"
	done
}
