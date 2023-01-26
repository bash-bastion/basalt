# shellcheck shell=bash

init.assert_bash_version() {
	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		printf '%s\n' 'Fatal: Basalt: Basalt requires at least Bash version 4.3' >&2
		return 1
	fi
}

init.get_global_repo_path() {
	unset -v REPLY; REPLY=

	local basalt_global_repo=
	if [ -L "$0" ]; then # Only subshell when necessary
		if ! basalt_global_repo=$(readlink -f "$0"); then
			printf '%s\n' "printf '%s\n' \"Fatal: Basalt: Invocation of readlink failed\" >&2"
			printf '%s\n' 'exit 1'
		fi
		basalt_global_repo=${basalt_global_repo%/*}
	else
		basalt_global_repo=${0%/*}
	fi
	basalt_global_repo=${basalt_global_repo%/*}
	basalt_global_repo=${basalt_global_repo%/*}

	REPLY=$basalt_global_repo
}

init.print_package_init() {
	init.get_global_repo_path
	local basalt_global_repo="$REPLY"

	printf '%s\n' "# shellcheck shell=bash

_____package_init() {
		export BASALT_GLOBAL_REPO=\"$basalt_global_repo\"
}"
	cat "$basalt_global_repo/pkg/share/scripts/basalt-package-init.sh"
}

init.common_init() {
	local basalt_dirname="$1"

	set -eo pipefail
	shopt -s dotglob extglob globasciiranges globstar lastpipe nullglob shift_verbose
	if ((BASH_VERSINFO[0] >= 6 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 2))); then
		shopt -s noexpand_translation
	fi
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
		LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
		LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export GIT_TERMINAL_PROMPT=0

	for f in "$basalt_dirname"/pkg/vendor/bash-{core,std,term,toml}/pkg/src/**/?*.sh; do
		source "$f"
	done; unset -v f
	for f in "$basalt_dirname"/pkg/src/{commands,plumbing,util}/?*.sh; do
		source "$f"
	done; unset -v f
}
