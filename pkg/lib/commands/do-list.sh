# shellcheck shell=bash

has_invalid_packages='no'

do-list() {
	local flag_fetch='no'
	local flag_format=

	util.setup_mode

	local -a pkgs=()
	for arg; do
		case "$arg" in
		--fetch)
			flag_fetch='yes'
			;;
		--format=*)
			IFS='=' read -r discard flag_format <<< "$arg"

			if [ -z "$flag_format" ]; then
				die "Format cannot be empty"
			fi
			;;
		-*)
			die "Flag '$arg' not recognized"
			;;
		*)
			pkgs+=("$arg")
			;;
		esac
	done

	# If packages are specified
	if (( ${#pkgs[@]} > 0 )); then
		for repoSpec in "${pkgs[@]}"; do
			util.extract_data_from_input "$repoSpec"
			local site="$REPLY2"
			local package="$REPLY3"
			local ref="$REPLY4"

			if [ -n "$ref" ]; then
				die "Refs must be omitted when listing packages. Remove ref '@$ref'"
			fi

			if [ -d "$BPM_PACKAGES_PATH/$site/$package" ]; then
				echo_package_info "$BPM_PACKAGES_PATH/$site/$package" "$site" "${package%/*}" "${package#*/}" "$flag_fetch" "$flag_format"
			else
				die "Package '$site/$package' is not installed"
			fi
		done
	else
		# If no packages are specified, list all of them
		for namespace_path in "$BPM_PACKAGES_PATH"/*; do
			local glob_suffix=
			if [ "${namespace_path##*/}" = 'local' ]; then
				glob_suffix="/*"
			else
				glob_suffix="/*/*"
			fi

			for pkg_path in "$namespace_path"$glob_suffix; do
				util.extract_data_from_package_dir "$pkg_path"
				local site="$REPLY1"
				local user="$REPLY2"
				local repository="$REPLY3"

				echo_package_info "$pkg_path" "$site" "$user" "$repository" "$flag_fetch" "$flag_format"
			done
		done
	fi

	if [ "$has_invalid_packages" = 'yes' ]; then
		log.error "Some packages are installed in an outdated format. To fix this optimally, remove the '${BPM_PACKAGES_PATH%/*}' directory and reinstall all the packages that were deleted in the process. This procedure is required in response to a one-time breaking change in how packages are stored"
	fi
}

echo_package_info() {
	local pkg_path="$1"
	local site="$2"
	local user="$3"
	local repository="$4"
	local flag_fetch="$5"
	local flag_format="$6"

	# Users that have installed packages before the switch to namespacing by
	# site domain name will print incorrectly. So, we check to make sure the site
	# url is actually is a domain name and not, for example, a GitHub username
	if [[ "$site" != *.* ]] && [ "$site" != 'local' ]; then
		has_invalid_packages='yes'
		return
	fi

	# Relative path location of the current package
	local id=
	if [ "$site" = 'local' ]; then
		id="$site/$repository"
	else
		id="$site/$user/$repository"
	fi

	# The information being outputed for a particular package
	# Ex.
	# github.com/tj/git-extras
	#   Status: Up to Date
	#   Branch: main\n
	local pkg_output=

	printf -v pkg_output "%s\n" "$id"

	if [ "$flag_format" != 'simple' ]; then
		if [ ! -d "$pkg_path/.git" ]; then
			die "Package '$id' is not a Git repository. Unlink or otherwise remove it at '$pkg_path'"
		fi

		local repo_branch_str= repo_revision_str= repo_outdated_str=

		repo_branch_str="Branch: $(git -C "$pkg_path" branch --show-current)"
		printf -v pkg_output "%s  %s\n" "$pkg_output" "$repo_branch_str"

		if git -C "$pkg_path" config remote.origin.url &>/dev/null; then
			if [ "$flag_fetch" = yes ]; then
				local git_output=
				if ! git_output="$(git -C "$pkg_path" fetch 2>&1)"; then
					printf "  --> %s\n" "Git output:"
					printf "    --> %s\n" "${git_output%.}"
				fi
			fi

			local git_tag= git_sha1=
			git_sha1="$(git -C "$pkg_path" rev-parse --short HEAD)"
			if git_tag="$(git -C "$pkg_path" describe --exact-match --tags 2>/dev/null)"; then
				repo_revision_str="Revision: $git_tag ($git_sha1)"
			else
				repo_revision_str="Revision: $git_sha1"
			fi
			printf -v pkg_output "%s  %s\n" "$pkg_output" "$repo_revision_str"

			# shellcheck disable=SC1083
			if [ "$(git -C "$pkg_path" rev-list --count HEAD...HEAD@{upstream})" -gt 0 ]; then
				repo_outdated_str="State: Out of date"
			else
				repo_outdated_str="State: Up to date"
			fi
			printf -v pkg_output "%s  %s\n" "$pkg_output" "$repo_outdated_str"
		fi
	fi

	printf "%s" "$pkg_output"
}
