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
	util.init_always

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
		init) shift; do-init "$@" ;;
		add) shift; do-add "$@" ;;
		remove) shift; do-remove "$@" ;;
		install) shift; do-install "$@" ;;
		list) shift; do-list "$@" ;;
		run) shift; do-run "$@" ;;
		version) shift; do-version "$@" ;;
		complete) shift; do-complete "$@" ;;
		global) shift
			case "$1" in
				init) shift; do-global-init "$@" ;;
				add) shift; do-global-add "$@" ;;
				remove) shift; do-global-remove "$@" ;;
				install) shift; do-global-install "$@" ;;
				list) shift; do-global-list "$@" ;;
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
