# shellcheck shell=bash

pkg.list_packages() {
	:
}

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
		pkgutil.get_allinfo "$pkg"
		local _pkg_type="$REPLY1"
		local _pkg_rawtext="$REPLY2"
		local _pkg_location="$REPLY3"
		local _pkg_fqlocation="$REPLY4"
		local _pkg_fsslug="$REPLY5"
		local _pkg_site="$REPLY6"
		local _pkg_fullname="$REPLY7"
		local _pkg_version="$REPLY8"

		if [ "$_pkg_type" = 'local' ]; then
			rm -rf "$BASALT_GLOBAL_DATA_DIR/store/packages/$_pkg_fsslug"
			cp -r "$_pkg_location" "$BASALT_GLOBAL_DATA_DIR/store/packages/$_pkg_fsslug"
			print.green 'Copied' "$_pkg_fsslug"
		elif [ "$_pkg_type" = 'remote' ]; then
			pkg.phase_download_tarball "$_pkg_type" "$_pkg_fqlocation" "$_pkg_site" "$_pkg_fullname" "$_pkg_version" "$_pkg_fsslug"
			pkg.phase_extract_tarball "$_pkg_fsslug"
		else
			print.die "Protocol not recognized. Only 'file://' and 'https://' are supported"
		fi

		# Install transitive dependencies if they exist
		local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages/$_pkg_fsslug"
		if [ -f "$package_dir/basalt.toml" ]; then
			if bash_toml.quick_array_get "$package_dir/basalt.toml" 'run.dependencies'; then
				pkg.install_packages "$package_dir" 'strict' "${REPLY[@]}"
			fi
		fi

		# Only after all the transitive dependencies _for a particular direct dependency_ are installed do we
		# muck with the direct dependency itself
		pkg.phase_global_integration "$_pkg_fsslug"
	done; unset -v pkg
}

# @description Downloads package tarballs from the internet to the global store. If a git revision is specified, it
# will extract that revision after cloning the repository and using git-archive
pkg.phase_download_tarball() {
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"
	local version="$5"
	local package_id="$6"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'
	# 'site' not required if  "$repo_type" is 'local'
	ensure.nonzero 'package'
	ensure.nonzero 'version'

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
		if bash_toml.quick_array_get "$project_dir/basalt.toml" 'run.dependencies'; then
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
		pkgutil.get_allinfo "$pkg"
		local _pkg_type="$REPLY1"
		local _pkg_rawtext="$REPLY2"
		local _pkg_location="$REPLY3"
		local _pkg_fqlocation="$REPLY4"
		local _pkg_fsslug="$REPLY5"
		local _pkg_site="$REPLY6"
		local _pkg_fullname="$REPLY7"
		local _pkg_version="$REPLY8"

		local package_id="$_pkg_fsslug"

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
			if bash_toml.quick_array_get "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id/basalt.toml" 'run.dependencies'; then
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
set -ETeo pipefail
shopt -s shift_verbose
if ((BASH_VERSINFO[0] >= 6 || (BASH_VERSINFO[0] == 5 && BASH_VERSINFO[1] >= 2))); then
	shopt -s noexpand_translation
fi

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
		if bash_toml.quick_array_get "$project_dir/basalt.toml" 'run.sourceDirs'; then
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
			if bash_toml.quick_string_get "$project_dir/basalt.toml" "run.setOptions.$option"; then
				if [ "$REPLY" = 'on' ]; then
					str+="set -o $option"$'\n'
				elif [ "$REPLY" = 'off' ]; then
					str+="set +o $option"$'\n'
				else
					print.die "Value of '$option' must be either 'on' or 'off'"
				fi
			fi
		done; unset -v option
		if [ -n "$str" ]; then
			printf -v content_all '%s%s\n' "$content_all" "$str"
		fi

		# Shopt options
		local str=
		for option in autocd assoc_expand_once cdable_vars cdspell checkhash checkjobs checkwinsize \
				cmdhist compat31 compat32 compat40 compat41 compat42 compat43 compat44 complete_fullquote \
				direxpand dirspell dotglob execfail expand_aliases extdebug extglob extquote failglob \
				force_fignore globasciiranges globstar gnu_errfmt histappend histreedit histverify hostcomplete \
				huponexit inherit_errexit interactive_comments lastpipe lithist localvar_inherit localvar_unset \
				login_shell mailwarn no_empty_cmd_completion nocaseglob nocasematch nullglob progcomp \
				progcomp_alias promptvars restricted_shell shift_verbose sourcepath xpg_echo; do
			if bash_toml.quick_string_get "$project_dir/basalt.toml" "run.shoptOptions.$option"; then
				if [ "$REPLY" = 'on' ]; then
					str+="shopt -s $option"$'\n'
				elif [ "$REPLY" = 'off' ]; then
					str+="shopt -u $option"$'\n'
				else
					print.die "Value of '$option' must be either 'on' or 'off'"
				fi
			fi
		done; unset -v option
		if [ -n "$str" ]; then
			printf -v content_all '%s%s\n' "$content_all" "$str"
		fi

		# Environment variables
		local str=
		if bash_toml.quick_object_get "$project_dir/basalt.toml" 'run.shellEnvironment'; then
			local var=
			for var in "${!REPLY[@]}"; do
				str+="export $var=\"${REPLY[$var]}\""$'\n'
			done; unset -v var
		fi
		if [ -n "$str" ]; then
			printf -v content_all '%s%s\n' "$content_all" "$str"
		fi

		# Now, overwrite each 'bin' so it works without Basalt,
		# but only for non-local files
		local package_dir="$BASALT_GLOBAL_DATA_DIR/store/packages"
		if [ "$package_dir" = "${project_dir:0:${#package_dir}}" ]; then
			core.shopt_push -s nullglob
			local files=("$project_dir"/pkg/bin/*)
			core.shopt_pop

			local f=
			for f in "${files[@]}"; do
				printf '%s\n\n' '#!/usr/bin/env bash

# This is an autogenerated file. This essentially does the same thing as
# the ./pkg/bin/* executables in the source code, but indirection layers
# have been removed so it can run without the installation of Basalt' > "$f"

				{
					printf '%s\n' "# CONTENT OF: \$BASALT_GLOBAL_REPO/pkg/src/util/init.sh"
					printf '%s\n' "# =============================================================================="
					cat "$BASALT_GLOBAL_REPO/pkg/src/util/init.sh"
					printf '\n'

					printf '%s\n' "# CONTENT OF: \$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh"
					printf '%s\n' "# =============================================================================="
					cat "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-global.sh"
					printf '\n'

					printf '%s\n' "# CONTENT OF: \$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh"
					printf '%s\n' "# =============================================================================="
					cat "$BASALT_GLOBAL_REPO/pkg/src/public/basalt-package.sh"
					printf '\n'
				} >> "$f"

				local filename="${f##*/}"
				printf '%s\n' "# CURRENT
basalt.package-init() {
	export BASALT_GLOBAL_DATA_DIR=\"${BASALT_GLOBAL_DATA_DIR:-\"${XDG_DATA_HOME:-$HOME/.local/share}/basalt\"}\"
	BASALT_PACKAGE_DIR=\"$project_dir\"
}

basalt.package-init
basalt.package-load

source \"\$BASALT_PACKAGE_DIR/pkg/src/bin/$filename.sh\"
'main.$filename' \"\$@\"" >> "$f"
			done; unset -v f
		fi
	else
		# Okay if no 'basalt.toml' file
		:
	fi

	# A 'source_all.sh' is generated for easy sourcing (and debugging)
	cat <<< "$content_all" > "$project_dir/.basalt/generated/source_all.sh"

	# Has successfully ran
	printf '%s\n' '# shellcheck shell=sh' "# This file exists for checking the success of 'basalt install'" > "$project_dir/.basalt/generated/done.sh"
}
