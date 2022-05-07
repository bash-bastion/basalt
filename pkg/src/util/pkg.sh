# shellcheck shell=bash

# @description Installs a pacakge and all its dependencies, relative to a
# particular project_dir. symlink_mode changes how components of its direct
# dependencies are synced
pkg.install_packages() {
	local project_dir="$1"
	local symlink_mode="$2"
	if ! shift 2; then
		core.panic 'Failed to shift'
	fi

	ensure.nonzero 'project_dir'
	ensure.nonzero 'symlink_mode'

	local pkg=
	for pkg; do
		util.get_package_info "$pkg"
		local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

		local package_id=
		if [[ $url == file://* ]]; then
			pkgutil.get_localpkg_info "$pkg"
			local pkg_path="$REPLY1"
			local pkg_name="$REPLY2"
			local pkg_id="$REPLY3"

			package_id=$pkg_id

			local target=
			if [ "${pkg_path:0:1}" = '/' ]; then
				target="$pkg_path"
			elif [ "${pkg_path:0:2}" = './' ]; then
				target="$BASALT_LOCAL_PROJECT_DIR/$pkg_path"
			else
				print.fatal "Specified local path '$pkg_path' not recognized"
			fi

			rm -rf "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id"
			cp -r "$target" "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id"
			print.green 'Copied' "$pkg_id"
		elif [[ $url == https://* ]]; then
			util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
			local package_id="$REPLY"

			# Download, extract
			pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version"
			pkg.phase_extract_tarball "$package_id"
		else
			print.die "Protocol not recognized. Only 'file://' and 'https://' are supported"
		fi

		# Install transitive dependencies if they exist
		local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
		if [ -f "$package_dir/basalt.toml" ]; then
			if util.get_toml_array "$package_dir/basalt.toml" 'dependencies'; then
				pkg.install_packages "$package_dir" 'strict' "${REPLY[@]}"
			fi
		fi

		# Only after all the transitive dependencies _for a particular direct dependency_ are installed do we
		# muck with the direct dependency itself
		pkg.phase_global_integration "$package_id"
	done; unset pkg
}

# @description Downloads package tarballs from the internet to the global store. If a git revision is specified, it
# will extract that revision after cloning the repository and using git-archive
pkg.phase_download_tarball() {
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'
	# 'site' not required if  "$repo_type" is 'local'
	ensure.nonzero 'package'
	ensure.nonzero 'version'

	util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	local download_dest="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	mkdir -p "${download_dest%/*}"

	# Use cache if it already exists
	if [ -e "$download_dest" ]; then
		print.green "Downloaded" "$package_id (cached)"
		return
	fi

	# Only try to download a release if the repository is actually a remote URL
	if [ "$repo_type" = remote ]; then
		util.get_tarball_url "$site" "$package" "$version"
		local download_url="$REPLY"

		if curl -fLso "$download_dest" "$download_url"; then
			if ! util.file_is_targz "$download_dest"; then
				rm -rf "$download_dest"
				print.die "File '$download_dest' is not actually a tarball"
			fi

			print.green "Downloaded" "$package_id"
			return
		fi

		# If cURL fails, this is OK, since the 'version' could be an actual ref. In that case,
		# download the package as below. It does this automatically for 'local' packages
	fi

	# TODO Print warning if a local dependency has a dirty index
	if [ "$repo_type" = 'local' ]; then
		:
		# print.warn "Local dependency at '$url' has a dirty index"
	fi

	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
	if ! git clone --quiet "$url" "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id"; then
		print.die "Could not clone repository for $package_id"
	fi

	if ! git -C "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" archive --prefix="prefix/" -o "$download_dest" "$version" 2>/dev/null; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch" "$download_dest"
		print.die "Could not download archive or extract archive from temporary Git repository of $package_id"
	fi
	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"

	if ! util.file_is_targz "$download_dest"; then
		rm -rf "$download_dest"
		print.die "File '$download_dest' is not actually a tarball"
	fi

	print.green "Downloaded" "$package_id"
}

# @description Extracts the tarballs in the global store to a directory
pkg.phase_extract_tarball() {
	local package_id="$1"
	ensure.nonzero 'package_id'

	local tarball_src="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	# Use cache if it already exists
	if [ -d "$tarball_dest" ]; then
		print.green "Extracted" "$package_id (cached)"
		return
	fi

	# Actually extract
	mkdir -p "$tarball_dest"
	if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
		print.die "Error" "Could not extract package $package_id"
	else
		print.green "Extracted" "$package_id"
	fi

	# Ensure extraction actually worked
	if [ ! -d "$tarball_dest" ]; then
		print.die "Extracted tarball is not a directory at '$tarball_dest'"
	fi
}

# TODO: properly cache transformations
# @description This performs modifications a particular package in the global store
pkg.phase_global_integration() {
	local package_id="$1"
	ensure.nonzero 'package_id'

	local project_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	ensure.dir "$project_dir"
	if [ -f "$project_dir/basalt.toml" ]; then
		# Install dependencies
		if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
			pkg.phase_local_integration_recursive "$project_dir" 'yes' 'lenient' "${REPLY[@]}"
			pkg.phase_local_integration_nonrecursive "$project_dir"
		fi
	fi

	print.green "Transformed" "$package_id"
}

# Create a './.basalt' directory for a particular project directory
pkg.phase_local_integration_recursive() {
	unset REPLY; REPLY=
	local original_package_dir="$1"
	local is_direct="$2" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"
	local symlink_mode="$3"
	if ! shift 3; then
		core.panic 'Failed to shift'
	fi

	ensure.nonzero 'original_package_dir'
	ensure.nonzero 'is_direct'
	ensure.nonzero 'symlink_mode'

	if [[ "$symlink_mode" != @(strict|lenient) ]]; then
		util.die_unexpected_value 'symlink_mode'
	fi

	local pkg=
	for pkg; do
		util.get_package_info "$pkg"
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		local package_id=
		if [[ $url == file://* ]]; then
			pkgutil.get_localpkg_info "$pkg"
			local pkg_path="$REPLY1"
			local pkg_name="$REPLY2"
			local pkg_id="$REPLY3"

			echo v "$pkg_id"
			package_id=$pkg_id
		elif [[ $url == https://* ]]; then
			util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
			package_id="$REPLY"
		fi

		# Perform symlinking
		if [ "$is_direct" = yes ]; then
			symlink.package "$original_package_dir/.basalt/packages" "$package_id"
			symlink.bin_"$symlink_mode" "$original_package_dir/.basalt/packages" "$package_id"
		elif [ "$is_direct" = no ]; then
			symlink.package "$original_package_dir/.basalt/transitive/packages" "$package_id"
			symlink.bin_"$symlink_mode" "$original_package_dir/.basalt/transitive/packages" "$package_id" "$package_id"
		else
			util.die_unexpected_value 'is_direct'
		fi

		ensure.dir "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
		if [ -f "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" ]; then
			if util.get_toml_array "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'dependencies'; then
				pkg.phase_local_integration_recursive "$original_package_dir" 'no' 'strict' "${REPLY[@]}"
			fi
		fi
	done; unset pkg
}

# @description Generate scripts for './.basalt/generated' directory
pkg.phase_local_integration_nonrecursive() {
	local project_dir="$1"
	ensure.nonzero 'project_dir'

	if [ ! -d "$project_dir/.basalt/generated" ]; then
		mkdir -p "$project_dir/.basalt/generated"
	fi

	# Create generated files
	# shellcheck disable=SC2016
	local content_all='# shellcheck shell=bash

if [ -z "$BASALT_PACKAGE_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_PACKAGE_DIR is empty, but must exist"
	exit 1
fi

if [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_GLOBAL_DATA_DIR is empty, but must exist"
	exit 1
fi'$'\n'

	if [ -f "$project_dir/basalt.toml" ]; then
		# Source directories
		if util.get_toml_array "$project_dir/basalt.toml" 'sourceDirs'; then
			if ((${#REPLY[@]} > 0)); then
				# Convert the full '$project_dir' path into something that uses the environment variables
				local project_dir_short=
				if [ "$BASALT_LOCAL_PROJECT_DIR" = "${project_dir::${#BASALT_LOCAL_PROJECT_DIR}}" ]; then
					# shellcheck disable=SC2016
					project_dir_short='$BASALT_PACKAGE_DIR'
				elif [ "$BASALT_GLOBAL_DATA_DIR" = "${project_dir::${#BASALT_GLOBAL_DATA_DIR}}" ]; then
					project_dir_short="\$BASALT_GLOBAL_DATA_DIR${project_dir:${#BASALT_GLOBAL_DATA_DIR}}"
				else
					print.fatal "Unexpected path to project directory '$project_dir'"
				fi

				local source_dir=
				for source_dir in "${REPLY[@]}"; do
					if [ ! -d "$project_dir/$source_dir" ]; then
						print.warn "Directory does not exist at '$project_dir_short/$source_dir'"
					fi

					printf -v content_all '%s%s\n' "$content_all" "
# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
if [ -d \"$project_dir_short/$source_dir\" ]; then
	__basalt_found_file='no'
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in \"$project_dir_short/$source_dir\"/*; do
		if [ -f \"\$__basalt_f\" ]; then
			__basalt_found_file='yes'
			# shellcheck disable=SC1090
			source \"\$__basalt_f\"
		fi
	done; unset -v __basalt_f

	if [ \"\$__basalt_found_file\" = 'no' ]; then
		printf '%s\n' \"Warning: source_packages.sh: Specified source directory '$source_dir' at project '$project_dir_short' does not contain any files\" >&2
	fi
	unset -v __basalt_found_file
fi"
				done; unset -v source_dir
			fi
		fi
		content_all+=$'\n'

		# Set options
		local str=
		for option in allexport braceexpand emacs errexit errtrace functrace hashall histexpand \
				history ignoreeof interactive-commants keyword monitor noclobber noexec noglob nolog \
				notify nounset onecmd physical pipefail posix priviledged verbose vi xtrace; do
			if util.get_toml_string "$project_dir/basalt.toml" "$option"; then
				if [ "$REPLY" = 'on' ]; then
					str+="set -o $option"$'\n'
				elif [ "$REPLY" = 'off' ]; then
					str+="set +o $option"$'\n'
				else
					print.die "Value of '$option' must be either 'on' or 'off'"
				fi
			fi
		done; unset -v option
		printf -v content_all '%s%s\n' "$content_all" "$str"

		# Shopt options
		local str=
		for option in autocd assoc_expand_once cdable_vars cdspell checkhash checkjobs checkwinsize \
				cmdhist compat31 compat32 compat40 compat41 compat42 compat43 compat44 complete_fullquote \
				direxpand dirspell dotglob execfail expand_aliases extdebug extglob extquote failglob \
				force_fignore globasciiranges globstar gnu_errfmt histappend histreedit histverify hostcomplete \
				huponexit inherit_errexit interactive_comments lastpipe lithist localvar_inherit localvar_unset \
				login_shell mailwarn no_empty_cmd_completion nocaseglob nocasematch nullglob progcomp \
				progcomp_alias promptvars restricted_shell shift_verbose sourcepath xpg_echo; do
			if util.get_toml_string "$project_dir/basalt.toml" "$option"; then
				if [ "$REPLY" = 'on' ]; then
					str+="shopt -s $option"$'\n'
				elif [ "$REPLY" = 'off' ]; then
					str+="shopt -u $option"$'\n'
				else
					print.die "Value of '$option' must be either 'on' or 'off'"
				fi
			fi
		done; unset -v option
		printf -v content_all '%s%s\n' "$content_all" "$str"
	else
		# Okay if no 'basalt.toml' file
		:
	fi

	# A 'source_all.sh' is generated for easy sourcing (and debugging)
	cat <<< "$content_all" > "$project_dir/.basalt/generated/source_all.sh"

	# Has successfully ran
	printf '%s\n' '# shellcheck shell=sh' "# This file exists for checking the success of 'basalt install'" > "$project_dir/.basalt/generated/done.sh"
}
