# shellcheck shell=bash

# @description Downloads package tarballs from the internet to the global store. If a git revision is specified, it
# will extract that revision after cloning the repository and using git-archive
pkg-phase.download_tarball() {
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	local download_dest="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	mkdir -p "${download_dest%/*}"

	if [ ${DEBUG+x} ]; then
		print-indent.debug "Downloading" "$package_id | $download_dest"
	fi

	# Use cache if it already exists
	if [ -e "$download_dest" ]; then
		print-indent.info "Downloaded" "$package_id (cached)"
		return
	fi

	# Only try to download a release if the repository is actually a remote URL
	if [ "$repo_type" = remote ]; then
		util.get_tarball_url "$site" "$package" "$version"
		local download_url="$REPLY"

		if curl -fLso "$download_dest" "$download_url"; then
			if ! util.file_is_targz "$download_dest"; then
				rm -rf "$download_dest"
				print-indent.die "File '$download_dest' is not actually a tarball"
			fi

			print-indent.info "Downloaded" "$site/$package@$version"
			return
		else
			# This is OK, since the 'version' could be an actual ref. In that case,
			# download the package as below
			:
		fi
	fi

	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
	if ! git clone --quiet "$url" "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" 2>/dev/null; then
		print-indent.die "Could not clone repository for $package_id"
	fi

	if ! git -C "$BASALT_GLOBAL_DATA_DIR/scratch/$package_id" archive --prefix="prefix/" -o "$download_dest" "$version"; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"
		print-indent.die "Could not download archive or extract archive from temporary Git repository of $package_id"
	fi
	rm -rf "$BASALT_GLOBAL_DATA_DIR/scratch"

	if ! util.file_is_targz "$download_dest"; then
		rm -rf "$download_dest"
		print-indent.die "File '$download_dest' is not actually a tarball"
	fi

	print-indent.info "Downloaded" "$package_id"
}

# @description Extracts the tarballs in the global store to a directory
pkg-phase.extract_tarball() {
	local package_id="$1"

	local tarball_src="$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id.tar.gz"
	local tarball_dest="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	if [ ${DEBUG+x} ]; then
		print-indent.debug "Extracting" "$package_id | $tarball_dest"
	fi

	# Use cache if it already exists
	if [ -d "$tarball_dest" ]; then
		print-indent.info "Extracted" "$package_id (cached)"
		return
	fi

	# Actually extract
	mkdir -p "$tarball_dest"
	if ! tar xf "$tarball_src" -C "$tarball_dest" --strip-components 1 2>/dev/null; then
		print-indent.die "Error" "Could not extract package $package_id"
	else
		print-indent.info "Extracted" "$package_id"
	fi

	# Ensure extraction actually worked
	if [ ! -d "$tarball_dest" ]; then
		print-indent.die "Extracted tarball is not a directory at '$tarball_dest'"
	fi
}

# @description This performs modifications a particular package in the global store
pkg-phase.global-integration() {
	local package_id="$1"

	# TODO: move this up
	local project_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"

	# TODO: properly cache transformations

	if [ ${DEBUG+x} ]; then
		print-indent.debug "Transforming" "$project_dir"
	fi

	pkg-phase.local-integration "$project_dir" "$project_dir" 'yes'

	print-indent.info "Transformed" "$package_id"
}

# Create a './basalt_packages' directory for a particular project directory
pkg-phase.local-integration() {
	unset REPLY; REPLY=
	local original_package_dir="$1"
	local package_dir="$2"
	local is_direct="$3" # Whether the "$package_dir" dependency is a direct or transitive dependency of "$original_package_dir"

	if [ ! -d "$package_dir" ]; then
		# TODO: make internal
		print.die "A directory at '$package_dir' was expected to exist"
		return
	fi

	if [ -f "$package_dir/basalt.toml" ]; then
		if util.get_toml_array "$package_dir/basalt.toml" 'dependencies'; then
			local pkg=
			for pkg in "${REPLIES[@]}"; do
				util.get_package_info "$pkg"
				local repo_type="$REPLY1"
				local url="$REPLY2"
				local site="$REPLY3"
				local package="$REPLY4"
				local version="$REPLY5"
				# util.assert_package_valid "$site" "$package" "$version"

				util.get_package_id "$repo_type" "$url" "$site" "$package" "$version"
				local package_id="$REPLY"

				if [ "$is_direct" = yes ]; then
					pkg.symlink_package "$original_package_dir/basalt_packages/packages" "$package_id"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$package_id
				else
					pkg.symlink_package "$original_package_dir/basalt_packages/transitive/packages" "$package_id"
					# pkg.symlink_bin "$package_dir/basalt_packages/transitive" "$package_id"
				fi

				pkg-phase.local-integration "$original_package_dir" "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id" 'no'
			done
			unset pkg
		fi
	fi
}
