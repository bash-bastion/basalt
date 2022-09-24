# shellcheck shell=bash

init.ensure_bash_version() {
	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		printf '%s\n' 'Fatal: main.basalt: Basalt requires at least Bash version 4.3' >&2
		exit 1
	fi
}

init.full_initialization() {
	set -eo pipefail
	shopt -s extglob globasciiranges nullglob shift_verbose
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
		LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
		LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export GIT_TERMINAL_PROMPT=0

	# All files are already sourced when testing. This ensures stubs are not overriden
	if [ "$BASALT_IS_TESTING" != 'yes' ]; then
		if [ -z "$__basalt_dirname" ]; then
			printf '%s\n' "Fatal: main.basalt: Variable '__basalt_dirname' is empty"
			exit 1
		fi
		for f in "$__basalt_dirname"/pkg/vendor/bash-{core,std,term,toml}/pkg/src/**/?*.sh; do
			source "$f"
		done; unset -v f
		for f in "$__basalt_dirname"/pkg/src/{commands,plumbing,util}/?*.sh; do
			source "$f"
		done; unset -v f
	fi
}

init.print_package_init() {
	local basalt_global_repo="$1"

	cat <<EOF
basalt.package-init() {
	# basalt variables
	export BASALT_GLOBAL_REPO="$basalt_global_repo"
EOF
	cat <<"EOF"
	export BASALT_GLOBAL_DATA_DIR="${BASALT_GLOBAL_DATA_DIR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt"}"

	if [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		printf '%s\n' "Error: basalt.package-init: Variable '\$BASALT_GLOBAL_DATA_DIR' is empty" >&2
		exit 1
	fi

	# basalt global and internal functions
	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh" ]; then
		printf '%s\n' "Error: basalt.package-init: Failed to find file 'basalt-global.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh"

	if [ ! -f "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh" ]; then
		printf '%s\n' "Error: basalt.package-init: Failed to find file 'basalt-package.sh' in '\$BASALT_GLOBAL_REPO'" >&2
		exit 1
	fi
	source "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh"

	if [ -z "${BASALT_PACKAGE_DIR:-}" ]; then
		local __old_cd="$PWD"

		# Do not use "$0", since it won't work in some environments, such as Bats
		local __basalt_file="${BASH_SOURCE[0]}"
		if [ -L "$__basalt_file" ]; then
			local __basalt_target="$(readlink "$__basalt_file")"
			if ! cd "${__basalt_target%/*}"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd to '${__basalt_target%/*}'" >&2
				exit 1
			fi
		else
			if ! cd "${__basalt_file%/*}"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd to '${__basalt_file%/*}'" >&2
				exit 1
			fi
		fi

		# Note that this variable should not be exported. It can cause weird things to occur. For example,
		# if a Basalt local package called a command from a global package, things won't work since
		# 'BASALT_PACKAGE_DIR' would already be defined and won't be properly set for the global package
		if ! BASALT_PACKAGE_DIR="$(
			while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
				if ! cd ..; then
					exit 1
				fi
			done

			if [ "$PWD" = / ]; then
				exit 1
			fi

			printf '%s' "$PWD"
		)"; then
			printf '%s\n' "Error: basalt.package-init: Could not find basalt.toml" >&2
			if ! cd "$__old_cd"; then
				printf '%s\n' "Error: basalt.package-init: Could not cd back to '$__old_cd'" >&2
				exit 1
			fi
			exit 1
		fi

		if ! cd "$__old_cd"; then
			printf '%s\n' "Error: basalt.package-init: Could not cd back to '$__old_cd'" >&2
			exit 1
		fi
	fi
}
EOF
}
