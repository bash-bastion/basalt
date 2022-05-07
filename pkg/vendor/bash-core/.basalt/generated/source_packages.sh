# shellcheck shell=bash

if [ -z "$BASALT_PACKAGE_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_PACKAGE_DIR is empty, but must exist"
	exit 1
fi

if [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_GLOBAL_DATA_DIR is empty, but must exist"
	exit 1
fi

# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/public" ]; then
	__basalt_found_file='no'
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/public"/*; do
		if [ -f "$__basalt_f" ]; then
			__basalt_found_file='yes'
			# shellcheck disable=SC1090
			source "$__basalt_f"
		fi
	done; unset -v __basalt_f

	if [ "$__basalt_found_file" = 'no' ]; then
		printf '%s\n' "Warning: source_packages.sh: Specified source directory 'pkg/src/public' at project '$BASALT_PACKAGE_DIR' does not contain any files" >&2
	fi
	unset -v __basalt_found_file
fi

# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/util" ]; then
	__basalt_found_file='no'
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/util"/*; do
		if [ -f "$__basalt_f" ]; then
			__basalt_found_file='yes'
			# shellcheck disable=SC1090
			source "$__basalt_f"
		fi
	done; unset -v __basalt_f

	if [ "$__basalt_found_file" = 'no' ]; then
		printf '%s\n' "Warning: source_packages.sh: Specified source directory 'pkg/src/util' at project '$BASALT_PACKAGE_DIR' does not contain any files" >&2
	fi
	unset -v __basalt_found_file
fi

