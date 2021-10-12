# shellcheck shell=bash

do-run() {
	util.init_local

	local -a args=()
	for arg; do case "$arg" in
	--)
		shift
		break
		;;
	-*)
		bprint.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		shift
		;;
	esac done

	if ((${#args[@]} == 0)); then
		bprint.die "The name of an executable must be passed"
	fi

	if ((${#args[@]} > 1)); then
		bprint.die "The only argument must be the executable name"
	fi

	# Look in current package
	local bin_name="${args[0]}"
	if util.get_toml_array "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'binDirs'; then
		for bin_dir in "${REPLIES[@]}"; do
			for bin_file in "$BASALT_LOCAL_PROJECT_DIR/$bin_dir"/*; do
				if [ -f "$bin_file" ] && [ -x "$bin_file" ]; then
					util.deinit
					exec "$bin_file" "$@"
				elif [ -f "$bin_file" ]; then
					bprint.die "File '$bin_name' is found, but the package providing it has not made it executable"
				else
					bprint.die "No executable called '$bin_name' was found"
				fi
			done; unset bin_file
		done; unset bin_dir
	fi

	# Look in subdependencies
	local bin_file="$BASALT_LOCAL_PROJECT_DIR/.basalt/bin/$bin_name"
	if [ -f "$bin_file" ] && [ -x "$bin_file" ]; then
		util.deinit
		exec "$bin_file" "$@"
	elif [ -f "$bin_file" ]; then
		bprint.die "File '$bin_name' is found, but the package providing it has not made it executable"
	else
		bprint.die "No executable called '$bin_name' was found"
	fi
}
