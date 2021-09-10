# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

for f in "$PROGRAM_LIB_DIR"/{commands,plumbing,util}/?*.sh; do
	source "$f"
done

basalt.main() {
	for arg; do case "$arg" in
	--help|-h)
		util.show_help
		exit
		;;
	--version|-v)
		# TODO: version string out of date
		cat <<-EOF
		Version: v0.9.0
		EOF
		exit
		;;
	-*)
		die "Global flag '$arg' not recognized"
		;;
	*)
		break
		;;
	esac done

	BASALT_MODE='local'
	case "$1" in
		init) shift; do-init "$@" ;;
		add) shift; do-add "$@" ;;
		install) shift; do-install "$@" ;;
		link) shift; do-link "$@" ;;
		list) shift; do-list "$@" ;;
		complete) shift; do-complete "$@" ;;
		global)
			shift

			BASALT_MODE='global'
			case "$1" in
				init) shift; do-global-init "$@" ;;
				add) shift; do-global-add "$@" ;;
				upgrade) shift; do-global-upgrade "$@" ;;
				remove) shift; do-global-remove "$@" ;;
				link) shift; do-global-link "$@" ;;
				list) shift; do-global-list "$@" ;;
				*)
					if [ -n "$1" ]; then
						log.error "Global subcommand '$1' not valid"
					fi
					util.show_help
					return 1
					;;
			esac
			;;
		*)
			if [ -n "$1" ]; then
				log.error "Subcommand '$1' not valid"
			fi
			util.show_help
			return 1
			;;
	esac
}
