# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob
export LANG="C" LANGUAGE="C" LC_ALL="C"

for f in "$PROGRAM_LIB_DIR"/{commands,plumbing,util}/?*.sh; do
	source "$f"
done

basalt.main() {
	for arg; do case "$arg" in
	--help|-h)
		util.show_help
		return
		;;
	--version|-v)
		# TODO: version string out of date
		cat <<-EOF
		Version: v0.9.0
		EOF
		return
		;;
	-*)
		print.die_early "Top level flag '$arg' is not recognized"
		;;
	*)
		break
		;;
	esac done

	case "$1" in
		init) shift; do-init "$@" ;;
		add) shift; do-add "$@" ;;
		install) shift; do-install "$@" ;;
		link) shift; do-link "$@" ;;
		list) shift; do-list "$@" ;;
		complete) shift; do-complete "$@" ;;
		global) shift
			case "$1" in
				init) shift; do-global-init "$@" ;;
				add) shift; do-global-add "$@" ;;
				upgrade) shift; do-global-upgrade "$@" ;;
				remove) shift; do-global-remove "$@" ;;
				link) shift; do-global-link "$@" ;;
				list) shift; do-global-list "$@" ;;
				*)
					if [ -n "$1" ]; then
						print.die_early "Global subcommand '$1' is not a valid"
					else
						util.show_help
					fi
					;;
			esac
			;;
		*)
			if [ -n "$1" ]; then
				print.die_early "Subcommand '$1' is not valid"
			else
				util.show_help
			fi
			;;
	esac
}
