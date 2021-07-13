# shellcheck shell=bash

set -ETeo pipefail
shopt -s nullglob extglob

main() {
	: "${BPM_ROOT:="${XDG_DATA_HOME:-$HOME/.local/share}/bpm"}"
	: "${BPM_PREFIX:="$BPM_ROOT/cellar"}"
	: "${BPM_PACKAGES_PATH:="$BPM_PREFIX/packages"}"
	: "${BPM_INSTALL_BIN:="$BPM_PREFIX/bin"}"
	: "${BPM_INSTALL_MAN:="$BPM_PREFIX/man"}"
	: "${BPM_INSTALL_COMPLETIONS:="$BPM_PREFIX/completions"}"

	for f in "$PROGRAM_LIB_DIR"/{commands,util}/?*.sh; do
		source "$f"
	done

	local is_global='no'

	for arg; do
		case "$arg" in
		--help|-h)
			util.show_help
			exit
			;;
		--version|-v)
			cat <<-EOF
			Version: v0.6.0
			EOF
			exit
			;;
		--global|-g)
			is_global='yes'
			shift
			;;
		*)
			break
			;;
		esac
	done

	case "$1" in
	add)
		must_reset_bpm_vars "$is_global"

		shift
		do-add "$@"
		;;
	complete)
		shift
		do-complete "$@"
		;;
	echo)
		may_reset_bpm_vars "$is_global"

		shift
		do-echo "$@"
		;;
	init)
		shift
		do-init "$@"
		;;
	link)
		must_reset_bpm_vars "$is_global"

		shift
		do-link "$@"
		;;
	list)
		must_reset_bpm_vars "$is_global"

		shift
		do-list "$@"
		;;
	outdated)
		must_reset_bpm_vars "$is_global"

		shift
		bpm-outdated "$@"
		;;
	package-path)
		must_reset_bpm_vars "$is_global"

		shift
		bpm-package-path "$@"
		;;
	remove)
		must_reset_bpm_vars "$is_global"

		shift
		do-remove "$@"
		;;
	upgrade)
		must_reset_bpm_vars "$is_global"

		shift
		do-upgrade "$@"
		;;
	*)
		if [ -n "$1" ]; then
			log.error "Command '$1' not valid"
		fi
		util.show_help
		;;
	esac
}

must_reset_bpm_vars() {
	local is_global="$1"

	# TEST this
	if [ "$is_global" = 'no' ]; then
		local project_root_dir=
		if ! project_root_dir="$(util.get_project_root_dir)"; then
			die "No 'bpm.toml' file found. Please create one to install local packages or pass the '--global' option"
		fi

		do_set_bpm_vars "$project_root_dir"
	fi
}

may_reset_bpm_vars() {
	local is_global="$1"

	local project_root_dir=
	if project_root_dir="$(util.get_project_root_dir)"; then
		do_set_bpm_vars "$project_root_dir"
	fi
}

do_set_bpm_vars() {
	local project_root_dir="$1"
	ensure.non_zero 'project_root_dir' "$project_root_dir"

	BPM_ROOT="$project_root_dir"
	BPM_PREFIX="$project_root_dir/bpm_packages"
	BPM_PACKAGES_PATH="$BPM_PREFIX/packages"
	BPM_INSTALL_BIN="$BPM_PREFIX/bin"
	BPM_INSTALL_MAN="$BPM_PREFIX/man"
	BPM_INSTALL_COMPLETIONS="$BPM_PREFIX/completions"
}

main "$@"
