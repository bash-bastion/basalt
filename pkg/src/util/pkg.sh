# shellcheck shell=bash

# @description Installs a pacakge and all its dependencies, relative to a
# particular project_dir. symlink_mode changes how components of its direct
# dependencies are synced
pkg.install_packages() {
	local project_dir="$1"
	local symlink_mode="$2"
	shift 2

	ensure.nonzero 'project_dir'
	ensure.nonzero 'symlink_mode'

	local pkg=
	for pkg; do
		util.get_package_info "$pkg"
		local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

		local package_id=
		if [[ $pkg == file://* ]]; then
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
				bprint.fatal "Specified local path '$pkg_path' not recognized"
			fi

			# TODO: rsync?
			rm -rf "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id"
			cp -r "$target" "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id"
			bprint.green 'Copied' "$pkg_id"
		elif [[ $pkg == https://* ]]; then
			util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
			local package_id="$REPLY"

			# Download, extract
			pkg.phase_download_tarball "$repo_type" "$url" "$site" "$package" "$version"
			pkg.phase_extract_tarball "$package_id"
		else
			bprint.die "Protocol not recognized. Only 'file://' and 'https://' are supported"
		fi

		# Install transitive dependencies if they exist
		local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
		if [ -f "$package_dir/basalt.toml" ]; then
			if util.get_toml_array "$package_dir/basalt.toml" 'dependencies'; then
				pkg.install_packages "$package_dir" 'strict' "${REPLIES[@]}"
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
		bprint.green "Downloaded" "$package_id (cached)"
		return
	fi

	# Only try to download a release if the repository is actually a remote URL
	if [ "$repo_type" = remote ]; then
		util.get_tarball_url "$site" "$package" "$version"
		local download_url="$REPLY"

		if curl -fLso "$download_dest" "$download_url"; then
			if ! util.file_is_targz "$download_dest"; then
				rm -rf "$download_dest"
				bprint.die "File '$download_dest' is not actually a tarball"
			fi

			bprint.green "Downloaded" "$package_id"
			return
		fi

		# If cURL fails, this is OK, since the 'version' could be an actual ref. In that case,
		# download the package as below. It does this automatically for 'local' packages
	fi

	# TODO Print warning if a local dependency has a dirty index
	if [ "$repo_type" = 'local' ]; then
		:
		# bprint.warn "Local dependency at '$url' has a dirty index"
	fi

	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
	if ! git clone --quiet "$url" "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id"; then
		bprint.die "Could not clone repository for $package_id"
	fi

	if ! git -C "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" archive --prefix="prefix/" -o "$download_dest" "$version" 2>/dev/null; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch" "$download_dest"
		bprint.die "Could not download archive or extract archive from temporary Git repository of $package_id"
	fi
	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"

	if ! util.file_is_targz "$download_dest"; then
		rm -rf "$download_dest"
		bprint.die "File '$download_dest' is not actually a tarball"
	fi

	bprint.green "Downloaded" "$package_id"
}

# @description Extracts the tarballs in the global store to a directory
pkg.phase_extract_tarball() {
	local package_id="$1"
	ensure.nonzero 'package_id'

	local tarball_src="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	# Use cache if it already exists
	if [ -d "$tarball_dest" ]; then
		bprint.green "Extracted" "$package_id (cached)"
		return
	fi

	# Actually extract
	mkdir -p "$tarball_dest"
	if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
		bprint.die "Error" "Could not extract package $package_id"
	else
		bprint.green "Extracted" "$package_id"
	fi

	# Ensure extraction actually worked
	if [ ! -d "$tarball_dest" ]; then
		bprint.die "Extracted tarball is not a directory at '$tarball_dest'"
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
			pkg.phase_local_integration_recursive "$project_dir" 'yes' 'lenient' "${REPLIES[@]}"
			pkg.phase_local_integration_nonrecursive "$project_dir"
		fi
	fi

	bprint.green "Transformed" "$package_id"
}

# Create a './.basalt' directory for a particular project directory
pkg.phase_local_integration_recursive() {
	unset REPLY; REPLY=
	local original_package_dir="$1"
	local is_direct="$2" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"
	local symlink_mode="$3"
	if ! shift 3; then
		bprint.fatal "Failed to shift"
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
		if [[ $pkg == file://* ]]; then
			pkgutil.get_localpkg_info "$pkg"
			local pkg_path="$REPLY1"
			local pkg_name="$REPLY2"
			local pkg_id="$REPLY3"

			package_id=$pkg_id
		elif [[ $pkg == https://* ]]; then
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
				pkg.phase_local_integration_recursive "$original_package_dir" 'no' 'strict' "${REPLIES[@]}"
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
	local content=
	if [ -f "$project_dir/basalt.toml" ]; then
		if util.get_toml_array "$project_dir/basalt.toml" 'sourceDirs'; then
			if ((${#REPLIES[@]} > 0)); then
				# Convert the full '$project_dir' path into something that uses the environment variables
				local project_dir_short=
				if [ "$BASALT_LOCAL_PROJECT_DIR" = "${project_dir::${#BASALT_LOCAL_PROJECT_DIR}}" ]; then
					project_dir_short='$BASALT_PACKAGE_DIR'
				elif [ "$BASALT_GLOBAL_DATA_DIR" = "${project_dir::${#BASALT_GLOBAL_DATA_DIR}}" ]; then
					project_dir_short="\$BASALT_GLOBAL_DATA_DIR${project_dir:${#BASALT_GLOBAL_DATA_DIR}}"
				else
					bprint.fatal "Unexpected path to project directory '$project_dir'"
				fi

				# shellcheck disable=SC2016
				printf -v content '%s%s\n' "$content" '# shellcheck shell=bash

if [ -z "$BASALT_PACKAGE_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_PACKAGE_DIR is empty, but must exist"
	exit 1
fi

if [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_GLOBAL_DATA_DIR is empty, but must exist"
	exit 1
fi'

				for source_dir in "${REPLIES[@]}"; do
					printf -v content '%s%s\n' "$content" "
# Silently skip if directory doesn't exist since a corresponding warning will print during package installation
# TODO: only do the above for downloaded packages, but when sourcing current package a warning should show
if [ -d \"$project_dir_short/$source_dir\" ]; then
	# Works if nullglob is unset, given that there is no file called '*'
	for __basalt_f in \"$project_dir_short/$source_dir\"/*; do
		if [ -f \"\$__basalt_f\" ]; then
			# shellcheck disable=SC1090
			source \"\$__basalt_f\"
		fi
	done; unset __basalt_f
fi"
				done; unset source_dir

				if [ ! -d "$project_dir/.basalt/generated" ]; then
					mkdir -p "$project_dir/.basalt/generated"
				fi
				cat <<< "$content" > "$project_dir/.basalt/generated/source_packages.sh"
			fi
		fi

		# Set options
		printf '%s\n\n' "# shellcheck shell=bash" > "$project_dir/.basalt/generated/source_setoptions.sh"
		for option in allexport braceexpand emacs errexit errtrace functrace hashall histexpand \
				history ignoreeof interactive-commants keyword monitor noclobber noexec noglob nolog \
				notify nounset onecmd physical pipefail posix priviledged verbose vi xtrace; do
			if util.get_toml_string "$project_dir/basalt.toml" "$option"; then
				if [ "$REPLY" = 'on' ]; then
					printf '%s\n' "set -o $option" >> "$project_dir/.basalt/generated/source_setoptions.sh"
				elif [ "$REPLY" = 'off' ]; then
					printf '%s\n' "set +o $option" >> "$project_dir/.basalt/generated/source_setoptions.sh"
				else
					bprint.die "Value of '$option' be either 'on' or 'off'"
				fi
			fi
		done; unset option

		# Shopt options
		printf '%s\n\n' "# shellcheck shell=bash" > "$project_dir/.basalt/generated/source_shoptoptions.sh"
		for option in autocd assoc_expand_once cdable_vars cdspell checkhash checkjobs checkwinsize \
				cmdhist compat31 compat32 compat40 compat41 compat42 compat43 compat44 complete_fullquote \
				direxpand dirspell dotglob execfail expand_aliases extdebug extglob extquote failglob \
				force_fignore globasciiranges globstar gnu_errfmt histappend histreedit histverify hostcomplete \
				huponexit inherit_errexit interactive_comments lastpipe lithist localvar_inherit localvar_unset \
				login_shell mailwarn no_empty_cmd_completion nocaseglob nocasematch nullglob progcomp \
				progcomp_alias promptvars restricted_shell shift_verbose sourcepath xpg_echo; do
			if util.get_toml_string "$project_dir/basalt.toml" "$option"; then
				if [ "$REPLY" = 'on' ]; then
					printf '%s\n' "shopt -s $option" >> "$project_dir/.basalt/generated/source_shoptoptions.sh"
				elif [ "$REPLY" = 'off' ]; then
					printf '%s\n' "shopt -u $option" >> "$project_dir/.basalt/generated/source_shoptoptions.sh"
				else
					bprint.die "Value of '$option' be either 'on' or 'off'"
				fi
			fi
		done; unset option
	else
		# Okay if no 'basalt.toml' file
		:
	fi

	# A 'source_all.sh' is generated for easy sourcing (and for debugging)
	cat <<"EOF" > "$project_dir/.basalt/generated/source_all.sh"
# shellcheck shell=bash

if [ -z "$BASALT_PACKAGE_DIR" ]; then
	printf "%s\n" "Fatal: source_packages.sh: \$BASALT_PACKAGE_DIR is empty, but must exist"
	exit 1
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_packages.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_packages.sh"
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_setoptions.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_setoptions.sh"
fi

if [ -f "$BASALT_PACKAGE_DIR/.basalt/generated/source_shoptoptions.sh" ]; then
	source "$BASALT_PACKAGE_DIR/.basalt/generated/source_shoptoptions.sh"
fi
EOF

	# TODO: put version in here and if version is out of date, prompt to 'basalt install'
	# Has successfully ran
	printf '%s\n' '# shellcheck shell=sh' "# This file exists so it can be checked that 'basalt install' has been ran successfully" > "$project_dir/.basalt/generated/done.sh"
}