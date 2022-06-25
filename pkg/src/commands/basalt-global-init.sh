# shellcheck shell=bash
# shellcheck disable=SC2016

basalt-global-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		print.die "Shell not specified"
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		print.die "Shell not supported"
	fi

	# Get actual location of source code; only symlink when required
	local basalt_global_repo=
	if [ -L "$0" ]; then
		if ! basalt_global_repo=$(readlink -f "$0"); then
			printf '%s\n' "printf '%s\n' \"Error: basalt-package-init: Invocation of readlink failed\""
			printf '%s\n' 'exit 1'
		fi
		basalt_global_repo=${basalt_global_repo%/*}
	else
		basalt_global_repo=${0%/*}
	fi
	basalt_global_repo=${basalt_global_repo%/*}; basalt_global_repo=${basalt_global_repo%/*}

	# Variables
	printf '%s\n' '# Set variables'
	shell.variable_assignment 'BASALT_GLOBAL_REPO' "$basalt_global_repo"
	shell.variable_assignment 'BASALT_GLOBAL_DATA_DIR' "${BASALT_GLOBAL_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/basalt}"
	shell.variable_export 'BASALT_GLOBAL_REPO'
	shell.variable_export 'BASALT_GLOBAL_DATA_DIR'
	printf '\n'

	# Basalt
	printf '%s\n' '# For Basalt'
	shell.source '$BASALT_GLOBAL_REPO/pkg/src/public' 'basalt-global'
	shell.register_completion '$BASALT_GLOBAL_REPO/completions' 'basalt'
	printf '\n'

	# Basalt packages
	printf '%s\n' "# For Basalt packages"
	shell.path_prepend '$BASALT_GLOBAL_DATA_DIR/global/bin'
	shell.register_completions '$BASALT_GLOBAL_DATA_DIR/global/completion'
	printf '\n'
}
