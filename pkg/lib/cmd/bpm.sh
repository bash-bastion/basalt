# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

for f in "$PROGRAM_LIB_DIR"/{commands,commands-global,plumbing,util}/?*.sh; do
	source "$f"
done

_cmd_.bpm() {
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

	BPM_MODE='local'
	case "$1" in
		init) shift; do-init "$@" ;;
		add) shift; do-add "$@" ;;
		upgrade) shift; do-upgrade "$@" ;;
		remove) shift; do-remove "$@" ;;
		link) shift; do-link "$@" ;;
		prune) shift; do-prune "$@" ;;
		list) shift; do-list "$@" ;;
		complete) shift; do-complete "$@" ;;
		global)
			shift

			BPM_MODE='global'
			case "$1" in
				init) shift; do-init "$@" ;;
				add) shift; do-add "$@" ;;
				upgrade) shift; do-upgrade "$@" ;;
				remove) shift; do-remove "$@" ;;
				link) shift; do-link "$@" ;;
				prune) shift; do-prune "$@" ;;
				list) shift; do-list "$@" ;;
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
