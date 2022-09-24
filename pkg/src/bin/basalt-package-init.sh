# shellcheck shell=bash

# This command is similar to 'basalt global init bash', except that it is only used by
# Bash applications (and test initialization procedures of Bash libraries) to load in
# all the Basalt functions in the current shell context. It must be a binary rather
# than a function because any new Bash contexts won't inherit functions of previous
# contexts, but will inherit the PATH, BASALT_GLOBAL_REPO, and BASALT_GLOBAL_DATA_DIR.
# This file is executed by './pkg/bin/basalt-package-init'. We are able to use 'exit 1'
# since these functions must only be called in a fresh Bash context

main.basalt-package-init() {
	if [ "$BASALT_IS_TESTING" != 'yes' ]; then
		if [ -z "$__basalt_dirname" ]; then
			printf '%s\n' "Fatal: main.basalt: Variable '__basalt_dirname' is empty"
			exit 1
		fi
		source "$__basalt_dirname/pkg/src/util/init.sh"
	fi

	init.ensure_bash_version

	# Set main variables (WET)
	local basalt_global_repo=
	if [ -L "$0" ]; then # Only subshell when necessary
		if ! basalt_global_repo=$(readlink -f "$0"); then
			printf '%s\n' "printf '%s\n' \"Error: basalt-package-init: Invocation of readlink failed\" >&2"
			printf '%s\n' 'exit 1'
		fi
		basalt_global_repo=${basalt_global_repo%/*}
	else
		basalt_global_repo=${0%/*}
	fi
	basalt_global_repo=${basalt_global_repo%/*}; basalt_global_repo=${basalt_global_repo%/*}

	init.print_package_init "$basalt_global_repo"
}
