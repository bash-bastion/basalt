# shellcheck shell=bash

if ! ((BASH_VERSINFO[0] >= 5 || (BASH_VERSINFO[0] >= 4 && BASH_VERSINFO[1] >= 3) )); then
  printf '%s\n' 'Basalt requires at least Bash version 4.3'
  exit 1
fi

set -ETeo pipefail
shopt -s nullglob extglob
export LANG="C" LANGUAGE="C" LC_ALL="C"
export GIT_TERMINAL_PROMPT=0

# shellcheck disable=SC2154
for f in "$__basalt_dirname"/pkg/lib/{commands,plumbing,util}/?*.sh; do
	source "$f"
done

main.basalt() {
	for arg; do case "$arg" in
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
		bprint.die "Top level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done

	case "$1" in
	init)
		shift
		do-init "$@" ;;
	add)
		shift
		util.init_always
		do-add "$@" ;;
	remove)
		shift
		util.init_always
		do-remove "$@" ;;
	install)
		shift
		util.init_always
		do-install "$@" ;;
	list)
		shift
		util.init_always
		do-list "$@" ;;
	run)
		shift
		util.init_always
		do-run "$@" ;;
	version)
		shift
		util.init_always
		do-version "$@" ;;
	complete)
		shift
		util.init_always
		do-complete "$@" ;;
	global)
		shift
		case "$1" in
		init)
			shift
			do-global-init "$@" ;;
		add)
			shift
			util.init_always
			do-global-add "$@" ;;
		remove)
			shift
			util.init_always
			do-global-remove "$@" ;;
		install)
			shift
			util.init_always
			do-global-install "$@" ;;
		list)
			shift
			util.init_always
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
