# shellcheck shell=bash

# @description This fufills the function of a 'basalt global install'
# command. Since that's not a real command, it does not have its own
# file in 'commands'; it's here instead
pkg.do-global-install() {
	if ! rm -rf "$BASALT_GLOBAL_DATA_DIR/global/basalt_packages"; then
		print-indent.die "Could not remove global 'basalt_packages' directory"
	fi

	local -a dependencies=()
	touch "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
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
		pkg-phase.download_tarball "$repo_type" "$url" "$site" "$package" "$version"
		pkg-phase.extract_tarball "$package_id"

		# Install transitive dependencies if they exist
		if [ -f "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" ]; then
			if util.get_toml_array "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'dependencies'; then
				pkg.install_package "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id" 'strict' "${REPLIES[@]}"
			fi
		fi

		# Only after all the dependencies are installed do we muck with the package
		pkg-phase.global-integration "$package_id"
	done
	unset pkg

	# Only if all the previous modifications to the global package store has been successfull
	# do we symlink to it from the local project directory. This is in a separate loop so we
	# don't run into weird recursion issues with 'pkg.install_package'
	pkg-phase.local-integration "$project_dir" 'yes' "$symlink_mode" "$@"
}
