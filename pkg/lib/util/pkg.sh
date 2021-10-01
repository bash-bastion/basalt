# shellcheck shell=bash

# @description This fufills the function of a 'basalt global install'
# command. Since that's not a real command, it does not have its own
# file in 'commands'; it's here instead
pkg.do-global-install() {
	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/.basalt"; then
		print.indent-die "Could not remove global '.basalt' directory"
	fi

	local -a dependencies=()
	readarray -t dependencies < "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
	pkg.install_package "$BASALT_GLOBAL_DATA_DIR/global" 'lenient' "${dependencies[@]}"
}

# @description Installs a pacakge and all its dependencies, relative to a
# particular project_dir. symlink_mode changes how components of its direct
# dependencies are synced
pkg.install_package() {
	local project_dir="$1"
	local symlink_mode="$2"
	shift 2

	ensure.nonzero 'project_dir'
	ensure.nonzero 'symlink_mode'

	# TODO: save the state and have rollback feature

	local pkg=
	for pkg; do
		if ! util.get_package_info "$pkg"; then
			print.die "String '$pkg' does not look like a package"
		fi
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
		local package_id="$REPLY"

		# Download, extract
		pkg.phase-download_tarball "$repo_type" "$url" "$site" "$package" "$version"
		pkg.phase-extract_tarball "$package_id"

		# Install transitive dependencies if they exist
		if [ -f "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" ]; then
			if util.get_toml_array "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'dependencies'; then
				pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id" 'strict' "${REPLIES[@]}"
			fi
		fi

		# Only after all the dependencies are installed do we muck with the package
		pkg.phase-global-integration "$package_id"
	done
	unset pkg

	# Only if all the previous modifications to the global package store has been successfull
	# do we symlink to it from the local project directory. This is in a separate loop so we
	# don't run into weird recursion issues with 'pkg.install_package'
	pkg.phase-local-integration "$project_dir" 'yes' "$symlink_mode" "$@"
}

# @description Downloads package tarballs from the internet to the global store. If a git revision is specified, it
# will extract that revision after cloning the repository and using git-archive
pkg.phase-download_tarball() {
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

	if [ ${DEBUG+x} ]; then
		print.indent-light-cyan "Downloading" "$package_id | $download_dest"
	fi

	# Use cache if it already exists
	if [ -e "$download_dest" ]; then
		print.indent-green "Downloaded" "$package_id (cached)"
		return
	fi

	# Only try to download a release if the repository is actually a remote URL
	if [ "$repo_type" = remote ]; then
		util.get_tarball_url "$site" "$package" "$version"
		local download_url="$REPLY"

		if curl -fLso "$download_dest" "$download_url"; then
			if ! util.file_is_targz "$download_dest"; then
				rm -rf "$download_dest"
				print.indent-die "File '$download_dest' is not actually a tarball"
			fi

			print.indent-green "Downloaded" "$site/$package@$version"
			return
		else
			# This is OK, since the 'version' could be an actual ref. In that case,
			# download the package as below
			:
		fi
	fi

	# TODO Print warning if a local dependency has a dirty index
	if [ "$repo_type" = 'local' ]; then
		:
		# print.indent-yellow 'Warning' "Local dependency at '$url' has a dirty index"
	fi

	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
	if ! git clone --quiet "$url" "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" 2>/dev/null; then
		print.indent-die "Could not clone repository for $package_id"
	fi

	if ! git -C "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" archive --prefix="prefix/" -o "$download_dest" "$version"; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
		print.indent-die "Could not download archive or extract archive from temporary Git repository of $package_id"
	fi
	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"

	if ! util.file_is_targz "$download_dest"; then
		rm -rf "$download_dest"
		print.indent-die "File '$download_dest' is not actually a tarball"
	fi

	print.indent-green "Downloaded" "$package_id"
}

# @description Extracts the tarballs in the global store to a directory
pkg.phase-extract_tarball() {
	local package_id="$1"
	ensure.nonzero 'package_id'

	local tarball_src="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	if [ ${DEBUG+x} ]; then
		print.indent-light-cyan "Extracting" "$package_id | $tarball_dest"
	fi

	# Use cache if it already exists
	if [ -d "$tarball_dest" ]; then
		print.indent-green "Extracted" "$package_id (cached)"
		return
	fi

	# Actually extract
	mkdir -p "$tarball_dest"
	if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
		print.indent-die "Error" "Could not extract package $package_id"
	else
		print.indent-green "Extracted" "$package_id"
	fi

	# Ensure extraction actually worked
	if [ ! -d "$tarball_dest" ]; then
		print.indent-die "Extracted tarball is not a directory at '$tarball_dest'"
	fi
}

# TODO: properly cache transformations
# @description This performs modifications a particular package in the global store
pkg.phase-global-integration() {
	local package_id="$1"
	ensure.nonzero 'package_id'

	local project_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	if [ ${DEBUG+x} ]; then
		print.indent-light-cyan "Transforming" "$project_dir"
	fi

	ensure.dir "$project_dir"
	if [ -f "$project_dir/basalt.toml" ]; then
		local content=

		# Create shell scripts to quick source
		if util.get_toml_array "$project_dir/basalt.toml" 'sourceDirs'; then
			if ((${REPLIES[@]} > 0)); then
				local source_dir=
				for source_dir in "${REPLIES[@]}"; do
					printf -v content '%s%s\n' "$content" "for __basalt_f in \"\$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/$source_dir\"/*; do
  source \"\$__basalt_f\"
done"
				done
				unset source_dir

				printf -v content '%s%s' "$content" 'unset __basalt_f'

				if [ ! -d "$project_dir/.basalt/actions" ]; then
					mkdir -p "$project_dir/.basalt/actions"
				fi
				cat <<< "$content" > "$project_dir/.basalt/actions/source_package.sh"
			fi
		fi

		# Install dependencies
		if util.get_toml_array "$project_dir/basalt.toml" 'dependencies'; then
			pkg.phase-local-integration "$project_dir" 'yes' 'strict' "${REPLIES[@]}"
		fi
	fi

	print.indent-green "Transformed" "$package_id"
}

# Create a './.basalt' directory for a particular project directory
pkg.phase-local-integration() {
	unset REPLY; REPLY=
	local original_package_dir="$1"
	local is_direct="$2" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"
	local symlink_mode="$3"
	shift 3

	ensure.nonzero 'original_package_dir'
	ensure.nonzero 'is_direct'

	local pkg=
	for pkg; do
		if ! util.get_package_info "$pkg"; then
			print.die "String '$pkg' does not look like a package"
		fi
		local repo_type="$REPLY1"
		local url="$REPLY2"
		local site="$REPLY3"
		local package="$REPLY4"
		local version="$REPLY5"

		util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
		local package_id="$REPLY"

		if [ "$is_direct" = yes ]; then
			symlink.package "$original_package_dir/.basalt/packages" "$package_id"

			if [ "$symlink_mode" = 'strict' ]; then
				symlink.bin_strict "$original_package_dir/.basalt/packages" "$package_id"
			elif [ "$symlink_mode" = 'lenient' ]; then
				symlink.bin_lenient "$original_package_dir/.basalt/packages" "$package_id"
			else
				util.die_unexpected_value 'symlink_mode'
			fi
		elif [ "$is_direct" = no ]; then
			symlink.package "$original_package_dir/.basalt/transitive/packages" "$package_id"

			if [ "$symlink_mode" = 'strict' ]; then
				symlink.bin_strict "$original_package_dir/.basalt/transitive/packages" "$package_id" "$package_id"
			elif [ "$symlink_mode" = 'lenient' ]; then
				symlink.bin_lenient "$original_package_dir/.basalt/transitive/packages" "$package_id" "$package_id"
			else
				util.die_unexpected_value 'symlink_mode'
			fi
		else
			util.die_unexpected_value 'is_direct'
		fi

		ensure.dir "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"
		if [ -f "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" ]; then
			if util.get_toml_array "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'dependencies'; then
				pkg.phase-local-integration "$original_package_dir" 'no' 'strict' "${REPLIES[@]}"
			fi
		fi
	done
	unset pkg
}
