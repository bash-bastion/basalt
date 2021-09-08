# shellcheck shell=bash

# TODO: make this automatic
# TODO: prune local packages that are no longer in dependencies
do-prune() {
	util.init_command

	log.info "Pruning packages"

	for file in "$BASALT_INSTALL_BIN"/* "$BASALT_INSTALL_MAN"/*/* "$BASALT_INSTALL_COMPLETIONS"/{bash,zsh/{compsys,compctl},fish}/*; do
		local real_file=
		if ! real_file="$(readlink "$file")"; then
			die "Readlink '$file' unexpectedly failed"
		fi

		if [[ "${real_file:0:1}" == / && -e "$real_file" ]]; then
			# The only valid symlinks 'basalt' creates are absolute paths
			# to an existing file
			continue
		fi

		printf '  -> %s\n' "Unsymlinking broken symlink '$file'"
		if ! unlink "$file"; then
			die "Unlink '$file' unexpectedly failed"
		fi
	done
}