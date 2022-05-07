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
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/bin" ]; then
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/bin"/*; do
		if [ -f "$__basalt_f" ]; then
			# shellcheck disable=SC1090
			source "$__basalt_f"
		else
			printf '%s\n' "Warning: source_packages.sh: Source directory 'pkg/src/bin' does not exist in the project" >&2
		fi
	done; unset __basalt_f
fi

# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/commands" ]; then
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/commands"/*; do
		if [ -f "$__basalt_f" ]; then
			# shellcheck disable=SC1090
			source "$__basalt_f"
		else
			printf '%s\n' "Warning: source_packages.sh: Source directory 'pkg/src/commands' does not exist in the project" >&2
		fi
	done; unset __basalt_f
fi

# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/public" ]; then
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/public"/*; do
		if [ -f "$__basalt_f" ]; then
			# shellcheck disable=SC1090
			source "$__basalt_f"
		else
			printf '%s\n' "Warning: source_packages.sh: Source directory 'pkg/src/public' does not exist in the project" >&2
		fi
	done; unset __basalt_f
fi

# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d "$BASALT_PACKAGE_DIR/pkg/src/util" ]; then
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in "$BASALT_PACKAGE_DIR/pkg/src/util"/*; do
		if [ -f "$__basalt_f" ]; then
			# shellcheck disable=SC1090
			source "$__basalt_f"
		else
			printf '%s\n' "Warning: source_packages.sh: Source directory 'pkg/src/util' does not exist in the project" >&2
		fi
	done; unset __basalt_f
fi

