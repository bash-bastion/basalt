# shellcheck shell=bash

# @file util.sh
# @brief Utility functions

# @description Initialize variables required for non-global subcommands
util.init_local() {
	util.init_global

	local local_project_root_dir=
	if local_project_root_dir="$(
		while [ ! -f 'basalt.toml' ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				return 1
			fi
		done

		if [ "$PWD" = / ]; then
			return 1
		fi

		printf '%s' "$PWD"
	)"; then
		# shellcheck disable=SC2034
		BASALT_LOCAL_PROJECT_DIR="$local_project_root_dir"
	else
		bprint.die "Could not find a 'basalt.toml' file"
	fi
}

# @description Check for the initialization of variables essential for global subcommands
util.init_global() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		bprint.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt global init <shell>' in your shell configuration?"
	fi

	if ! command -v curl &>/dev/null; then
		bprint.die "Program 'curl' not installed. Please install curl"
	fi
	if ! command -v md5sum &>/dev/null; then
		bprint.die "Program 'md5sum' not installed. Please install md5sum"
	fi

	if [ ! -d "$BASALT_GLOBAL_REPO" ]; then
		mkdir -p "$BASALT_GLOBAL_REPO"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/global" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/global"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/store" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/store"
	fi
	if [ ! -f "$BASALT_GLOBAL_DATA_DIR/global/dependencies" ]; then
		touch "$BASALT_GLOBAL_DATA_DIR/global/dependencies"
	fi
	if [ ! -d "$BASALT_GLOBAL_DATA_DIR/store/packages/local" ]; then
		mkdir -p "$BASALT_GLOBAL_DATA_DIR/store/packages/local"
	fi

	# I would prefer to check the existence of the target directory as well, but that would mean if the user installs
	# a package that creates for example a 'completion' directory, it would not show up until 'basalt' is executed again
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/bin" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/bin" "$BASALT_GLOBAL_DATA_DIR/global/bin"
	fi
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/completion" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/completion" "$BASALT_GLOBAL_DATA_DIR/global/completion"
	fi
	if [ ! -L "$BASALT_GLOBAL_DATA_DIR/global/man" ]; then
		ln -sf "$BASALT_GLOBAL_DATA_DIR/global/.basalt/packages/man" "$BASALT_GLOBAL_DATA_DIR/global/man"
	fi
}

util.init_lock() {
	# Use a lock directory for Basalt if not under testing
	if [ -z "$BATS_TMPDIR" ]; then
		___basalt_lock_dir=
		if [ -n "$XDG_RUNTIME_DIR" ]; then
			___basalt_lock_dir="$XDG_RUNTIME_DIR/basalt.lock"
		else
			___basalt_lock_dir="$BASALT_GLOBAL_DATA_DIR/basalt.lock"
		fi
		if mkdir "$___basalt_lock_dir" 2>/dev/null; then
			trap 'util.deinit' INT TERM EXIT
		else
			bprint.die "Cannot run Basalt at this time because another Basalt process is already running (lock directory '$___basalt_lock_dir' exists)"
		fi
	fi
}

util.deinit() {
	rm -rf "$___basalt_lock_dir"
}

# TODO
util.get_full_path() {
	if ! REPLY=$(realpath "$1"); then
		bprint.fatal "Failed to execute 'realpath' successfully"
	fi
}

# @description Ensure the downloaded file is really a .tar.gz file...
util.file_is_targz() {
	local file="$1"

	ensure.nonzero 'file'

	local magic_byte=
	if magic_byte="$(od -An -N2 -x "$file")"; then
		if [[ ${magic_byte#* } != *'8b1f'* ]]; then
			return 1
		fi
	else
		return 1
	fi
}

# @description Abort with error message relating to unexpected value
util.die_unexpected_value() {
	local variable="$1"

	ensure.nonzero 'variable'

	local -n value="$variable"
	bprint.fatal "Variable '$variable' has unexpected value of '$value'"
}

# @description Get id of package we can use for printing
util.get_package_id() {
	local flag_allow_empty_version='no' # Allow for version to be empty
	for arg; do case $arg in
		--allow-empty-version) flag_allow_empty_version='yes'; if ! shift; then bprint.die 'Failed shift'; fi ;;
		-*) bprint.fatal "Flag '$arg' not recognized" ;;
		*) break ;;
	esac done
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'
	if [ "$repo_type" != 'local' ]; then
		ensure.nonzero 'site'
	fi
	if [ "$flag_allow_empty_version" = 'no' ]; then
		ensure.nonzero 'version'
	fi
	ensure.nonzero 'package'

	local maybe_version=
	if [ "$flag_allow_empty_version" = 'no' ]; then
		maybe_version="@$version"
	else
		if [ -n "$version" ]; then
			maybe_version="@$version"
		fi
	fi

	if [ "$repo_type" = 'remote' ]; then
		REPLY="$site/${package}$maybe_version"
	elif [ "$repo_type" = 'local' ]; then
		REPLY="local/${url##*/}${maybe_version}"
	else
		util.die_unexpected_value 'repo_type'
	fi
}

## Larger Utilities (have tests)

# @description Check if the package exists (either as a remote URL or file)
util.does_package_exist() {
	local repo_type="$1"
	local url="$2"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'

	if [ "$repo_type" = 'remote' ]; then
		# TODO: make this cleaner (use GitHub, GitLab, etc. API)?
		if ! curl -LsfIo /dev/null --connect-timeout 1 --max-time 2.5 --retry 0 "$url"; then
			return 1
		fi
	elif [ "$repo_type" = 'local' ]; then
		# Assume '.git/' contains Git repository information
		if [ ! -d "${url:7}/.git" ]; then
			return 1
		fi
	else
		util.die_unexpected_value 'repo_type'
	fi

	return 0
}

# @description Get the latest package version
util.get_latest_package_version() {
	unset REPLY; REPLY=
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"

	ensure.nonzero 'repo_type'
	ensure.nonzero 'url'
	# 'site' not required if  "$repo_type" is 'local'
	ensure.nonzero 'package'

	# TODO: will it get beta/alpha/pre-releases??

	# Get the latest pacakge version that has been released
	if [ "$repo_type" = remote ]; then
		if [ "$site" = 'github.com' ]; then
			local latest_package_version=
			if latest_package_version="$(
				curl -LsS "https://api.github.com/repos/$package/releases/latest" \
					| awk -F '"' '{ if($2 == "tag_name") print $4 }'
			)" && [[ "$latest_package_version" == v* ]]; then
				REPLY="$latest_package_version"
				return
			fi
		else
			bprint.warn "Could not automatically retrieve latest release for '$package' since '$site' is not supported. Falling back to retrieving latest commit"
		fi
	fi

	# If there is not an official release, then just get the latest commit of the project
	local latest_commit=
	if latest_commit="$(
		git ls-remote "$url" | awk '{ if($2 == "HEAD") print $1 }'
	)"; then
		REPLY="$latest_commit"
		return
	fi

	bprint.die "Could not get latest release or commit for package '$package'"
}

util.get_package_info() {
	unset REPLY{1,2,3,4,5}
	REPLY1=; REPLY2=; REPLY3=; REPLY4=; REPLY5=
	local input="$1"
	ensure.nonzero 'input'

	local regex1="^https?://"
	local regex2="^file://"
	local regex3="^git@"
	if [[ "$input" =~ $regex1 ]]; then
		local site= package=

		input="${input#http?(s)://}"
		ref="${input##*@}"
		if [ "$ref" = "$input" ]; then ref=; fi
		input="${input%@*}"
		input="${input%.git}"

		IFS='/' read -r site package <<< "$input"

		REPLY1='remote'
		REPLY2="https://$input.git"
		REPLY3="$site"
		REPLY4="$package"
		REPLY5="$ref"
	elif [[ "$input" =~ $regex2 ]]; then
		local ref= dir=

		input="${input#file://}"
		IFS='@' read -r dir ref <<< "$input"

		REPLY1='local'
		REPLY2="file://$dir"
		REPLY3=
		REPLY4="${dir##*/}"
		REPLY5="$ref"
	elif [[ "$input" =~ $regex3 ]]; then
		local site= package=

		input="${input#git@}"
		input="${input%.git}"

		IFS=':' read -r site package <<< "$input"

		REPLY1='remote'
		REPLY2="git@$input"
		REPLY3="$site"
		REPLY4="$package"
		REPLY5=
	else
		local site= package= ref=
		input="${input%.git}"

		if [[ "$input" == */*/* ]]; then
			IFS='/' read -r site package <<< "$input"
		elif [[ "$input" = */* ]]; then
			site="github.com"
			package="$input"
		else
			bprint.die "String '$input' does not look like a package"
		fi

		if [[ "$package" == *@* ]]; then
			IFS='@' read -r package ref <<< "$package"
		fi

		REPLY1='remote'
		REPLY2="https://$site/$package.git"
		REPLY3="$site"
		REPLY4="$package"
		REPLY5="$ref"
	fi
}

# @description Get path to download tarball of particular package revision
util.get_tarball_url() {
	local site="$1"
	local package="$2"
	local ref="$3"

	ensure.nonzero 'site'
	ensure.nonzero 'package'
	ensure.nonzero 'ref'

	if [ "$site" = 'github.com' ]; then
		REPLY="https://github.com/$package/archive/refs/tags/$ref.tar.gz"
	elif [ "$site" = 'gitlab.com' ]; then
		REPLY="https://gitlab.com/$package/-/archive/$ref/${package#*/}-$ref.tar.gz"
	else
		bprint.die "Could not construct the location of the package tarball since '$site' is not supported"
	fi
}

# TODO: remove this
# If any version of a text dependency is installed
util.text_dependency_is_installed() {
	local text_file="$1"
	local dependency="$2"

	ensure.nonzero 'text_file'
	ensure.nonzero 'dependency'

	local line=
	while IFS= read -r line; do
		# TODO: use get_package_info
		if [ "${line%@*}" = "${dependency%@*}" ]; then
			return 0
		fi
	done < "$text_file"

	return 1
}

util.show_help() {
	cat <<"EOF"
Usage:
  basalt [--help|--version]
  basalt <local-subcommand> [args...]
  basalt global <global-subcommand> [args...]

Local subcommands:
  init --type=<app|lib>
    Creates a new Basalt package in the current directory

  add <package>
    Adds a dependency to the current local project

  remove [--force] <package>
    Removes a dependency from the current local project

  install
    Resolves and installs all dependencies for the current local
    project

  list [--fetch] [--format=<simple>] [package...]
    Lists particular dependencies for the current local project

  run <command>
    Runs a particular command from any particular locally installed package

  release [--yes] [new-version]
    Prepare and release a package

Global subcommands:
  init <shell>
    Prints shell code that must be evaluated during shell
    initialization for the proper functioning of Basalt

  add <package>
    Installs a global package

  remove [--force] [package...]
    Uninstalls a global package

  install
    Installs all global dependencies

  list [--fetch] [--format=<simple>] [package...]
    List all installed packages or just the specified ones

Examples:
  basalt global add tj/git-extras
  basalt global add github.com/tj/git-extras
  basalt global add https://github.com/tj/git-extras
  basalt global add git@github.com:tj/git-extras
  basalt global add hyperupcall/bash-args --branch=main
  basalt global add hyperupcall/bash-args@v0.6.1 # out of date
EOF
}
