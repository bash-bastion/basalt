# shellcheck shell=bash

# This command is similar to 'basalt global init bash', except that it is only used by
# Bash applications (and test initialization procedures of Bash libraries) to load in
# all the Basalt functions in the current shell context. It must be a binary rather
# than a function because any new Bash contexts won't inherit functions of previous
# contexts, but will inherit the PATH, BASALT_GLOBAL_REPO, and BASALT_GLOBAL_DATA_DIR.
# This file is executed by './pkg/bin/basalt-package-init'. We are able to use 'exit 1'
# since these functions must only be called in a fresh Bash context

main.basalt-package-init() {
	# Ensure 'init.sh' is sourced
	if [ "$BASALT_INTERNAL_IS_TESTING" != 'yes' ]; then
		if [ -n "$__basalt_dirname" ]; then
			# shellcheck source=../../../pkg/share/scripts/basalt-package-init.sh
			source "$__basalt_dirname/pkg/src/util/init.sh"
		else
			printf '%s\n' "Fatal: main.basalt-package-init: Variable '__basalt_dirname' is empty" >&2
			if (( $# > 0)); then
				exit 1
			else
				printf '%s\n' 'exit 1'
				exit 1
			fi
		fi
	fi

	if (( $# > 0 )); then
		if ! init.get_global_repo_path; then
			printf '%s\n' "Fatal: Basalt: Failed to find Basalt repository" >&2
			exit 1
		fi
		local global_basalt_global_repo="$REPLY"

		printf '%s\n' 'BASALT_INTERNAL_NEWINIT=yes'
		printf '%s\n' "BASALT_INTERNAL_ARGS=($*)"
		printf '%s\n' "BASALT_GLOBAL_REPO=\"$global_basalt_global_repo\""
		printf '%s\n' "source \"\$BASALT_GLOBAL_REPO/pkg/src/util/init.sh"\"
		printf '%s\n' "source \"\$BASALT_GLOBAL_REPO/pkg/share/scripts/basalt-package-init.sh"\"
	else
		if ! init.get_global_repo_path; then
			printf '%s\n' "Fatal: Basalt: Failed to find Basalt repository" >&2
			printf '%s\n' 'exit 1'
			exit 1
		fi
		local global_basalt_global_repo="$REPLY"

		printf '%s\n' 'BASALT_INTERNAL_NEWINIT=no'
		printf '%s\n' "BASALT_INTERNAL_ARGS=($*)"
		printf '%s\n' "BASALT_GLOBAL_REPO=\"$global_basalt_global_repo\""
		printf '%s\n' "source \"\$BASALT_GLOBAL_REPO/pkg/src/util/init.sh"\"
		printf '%s\n' "source \"\$BASALT_GLOBAL_REPO/pkg/share/scripts/basalt-package-init.sh"\"
	fi
}
