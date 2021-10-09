# shellcheck shell=bash

do-run() {
	util.init_local

	local -a args=()
	for arg; do case "$arg" in
	-*)
		print.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac done

	if ((${#args[@]} > 1)); then
		newindent.die "The only argument must be the executable name"
	fi

	local bin_name="${args[0]}"
	local bin_file="$BASALT_LOCAL_PROJECT_DIR/.basalt/bin/$bin_name"
	if [ -x "$bin_file" ]; then
		exec "$bin_file"
	elif [ -f "$bin_file" ]; then
		newindent.die "File '$bin_name' is found, but the package providing it has not made it executable"
	else
		newindent.die "No executable called '$bin_name' was found"
	fi
}
