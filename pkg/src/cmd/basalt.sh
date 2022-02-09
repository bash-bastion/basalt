# shellcheck shell=bash

main.basalt() {
	# Usually, a Basalt package won't have calls to `set`, `shopt`, `source`, etc., since
	# that is specified declaritively in `basalt.toml`. But, since that behavior is dependent
	# on Basalt, and Basalt doesn't bootstrap itself, we must setup the environment here.
	set -eo pipefail
	shopt -s extglob globasciiranges nullglob shift_verbose
	export LANG='C' LC_CTYPE='C' LC_NUMERIC='C' LC_TIME='C' LC_COLLATE='C' LC_MONETARY='C' \
		LC_MESSAGES='C' LC_PAPER='C' LC_NAME='C' LC_ADDRESS='C' LC_TELEPHONE='C' \
		LC_MEASUREMENT='C' LC_IDENTIFICATION='C' LC_ALL='C'
	export GIT_TERMINAL_PROMPT=0
	for f in "$__basalt_dirname"/pkg/src/{commands,plumbing,util}/?*.sh; do
		source "$f"
	done

	if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
		printf '%s\n' 'Error: main.basalt: Basalt requires at least Bash version 4.3' >&2
		exit 1
	fi

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
		bprint.die "Top-level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done


	case $1 in
	init)
		util.shift
		do-init "$@" ;;
	add)
		util.shift
		util.init_lock
		do-add "$@" ;;
	remove)
		util.shift
		util.init_lock
		do-remove "$@" ;;
	install)
		util.shift
		util.init_lock
		do-install "$@" ;;
	list)
		util.shift
		util.init_lock
		do-list "$@" ;;
	run)
		util.shift
		util.init_lock
		do-run "$@" ;;
	release)
		util.shift
		util.init_lock
		do-release "$@" ;;
	complete)
		util.shift
		util.init_lock
		do-complete "$@" ;;
	global)
		util.shift
		case $1 in
		init)
			util.shift
			do-global-init "$@" ;;
		add)
			util.shift
			util.init_lock
			do-global-add "$@" ;;
		remove)
			util.shift
			util.init_lock
			do-global-remove "$@" ;;
		install)
			util.shift
			util.init_lock
			do-global-install "$@" ;;
		list)
			util.shift
			util.init_lock
			do-global-list "$@" ;;
		*)
			if [ -n "$1" ]; then
				bprint.die "Global subcommand '$1' is not a valid"
			else
				util.show_help
			fi
			;;
		esac
		;;
	*)
		if [ -n "$1" ]; then
			bprint.die "Subcommand '$1' is not valid"
		else
			util.show_help
		fi
		;;
	esac
}
