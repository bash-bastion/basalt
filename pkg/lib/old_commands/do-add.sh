# shellcheck shell=bash

do-global-add() {
	util.init_command

	local flag_branch=
	local -a pkgs=()
	for arg; do case "$arg" in
	--branch=*)
		IFS='=' read -r discard flag_branch <<< "$arg"

		if [ -z "$flag_branch" ]; then
			die "Branch cannot be empty"
		fi
		;;
	-*)
		die "Flag '$arg' not recognized"
		;;
	*)
		pkgs+=("$arg")
		;;
	esac done

	if (( ${#pkgs[@]} == 0 )); then
		die "At least one package must be supplied"
	else
		util.extract_data_from_input "$repoSpec"
		local uri="$REPLY1"
		local site="$REPLY2"
		local package="$REPLY3"
		local version="$REPLY4"

		# TODO: if no version specified, automatically use latest

		pkg.download_package_tarball
	fi
}
