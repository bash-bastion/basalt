# shellcheck shell=bash

# Usually, a Basalt package won't have calls to `set`, `shopt`, `source`, etc., since
# that is specified declaritively in `basalt.toml`. But, since that behavior is dependent
# on Basalt, and Basalt doesn't bootstrap itself, we must setup the environment here.
# TODO: Currently a bug that the following declaration is needed top-level. This is to
# ensure the same options are set in the testing environment, _but_ it leaks into
# the call to 'basalt-package-init' (which is normally a separate Bash context)
set -eo pipefail
shopt -s extglob globasciiranges nullglob shift_verbose
export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
	LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
	LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
export GIT_TERMINAL_PROMPT=0

main.basalt() {
	# All files are already sourced when testing. This ensures stubs are not overriden
	if [ "$BASALT_IS_TESTING" != 'yes' ]; then
		if [ -z "$__basalt_dirname" ]; then
			printf '%s\n' "Fatal: main.basalt: Variable '__basalt_dirname' is empty"
			exit 1
		fi
		# Specify 'BASALT_PACKAGE_DIR' as a quick hack so the vendored packages work
		BASALT_PACKAGE_DIR="$__basalt_dirname/pkg/vendor/bash-core" source "$__basalt_dirname/pkg/vendor/bash-core/.basalt/generated/source_all.sh"
		BASALT_PACKAGE_DIR="$__basalt_dirname/pkg/vendor/bash-core" source "$__basalt_dirname/pkg/vendor/bash-term/.basalt/generated/source_all.sh"
		for f in "$__basalt_dirname"/pkg/src/{commands,plumbing,util}/?*.sh; do
			source "$f"
		done
	fi

	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		printf '%s\n' 'Fatal: main.basalt: Basalt requires at least Bash version 4.3' >&2
		exit 1
	fi

	local arg=
	for arg; do case $arg in
	--help|-h)
		util.show_help
		exit
		;;
	--version|-v)
		cat <<-EOF
		Version: v0.9.0
		EOF
		exit
		;;
	-*)
		print.die "Top-level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done; unset -v arg


	case $1 in
	init)
		if ! shift; then core.panic 'Failed to shift'; fi
		basalt-init "$@" ;;
	add)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-add "$@" ;;
	remove)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-remove "$@" ;;
	install)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-install "$@" ;;
	list)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-list "$@" ;;
	run)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-run "$@" ;;
	release)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-release "$@" ;;
	complete)
		if ! shift; then core.panic 'Failed to shift'; fi
		util.init_lock
		basalt-complete "$@" ;;
	global)
		if ! shift; then core.panic 'Failed to shift'; fi
		case $1 in
		init)
			if ! shift; then core.panic 'Failed to shift'; fi
			basalt-global-init "$@" ;;
		add)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-add "$@" ;;
		remove)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-remove "$@" ;;
		install)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-install "$@" ;;
		list)
			if ! shift; then core.panic 'Failed to shift'; fi
			util.init_lock
			basalt-global-list "$@" ;;
		*)
			if [ -n "$1" ]; then
				print.die "Global subcommand '$1' is not a valid"
			else
				util.show_help
			fi
			;;
		esac
		;;
	*)
		if [ -n "$1" ]; then
			print.die "Subcommand '$1' is not valid"
		else
			util.show_help
		fi
		;;
	esac
}
