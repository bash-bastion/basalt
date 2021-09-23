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
		print.die "Could not find a 'basalt.toml' file"
	fi
}

# @description Check for the initialization of variables essential for global subcommands
util.init_global() {
	if [ -z "$BASALT_GLOBAL_REPO" ] || [ -z "$BASALT_GLOBAL_DATA_DIR" ]; then
		print.die "Either 'BASALT_GLOBAL_REPO' or 'BASALT_GLOBAL_DATA_DIR' is empty. Did you forget to run add 'basalt init <shell>' in your shell configuration?"
	fi

	if ! command -v curl &>/dev/null; then
		print.die "Program 'curl' not installed. Please install curl"
	fi

	mkdir -p "$BASALT_GLOBAL_REPO" "$BASALT_GLOBAL_DATA_DIR"
}

# @description Ensure that a variable name is non-zero
util.ensure_nonzero() {
	local name="$1"

	if [ -z "$name" ]; then
		print.internal_die "Argument 'name' for function 'util.ensure_nonzero' is empty"
	fi

	local -n value="$name"
	if [ -z "$value" ]; then
		print.internal_die "Argument '$name' for function '${FUNCNAME[1]}' is empty"
	fi
}

# @description Ensure the downloaded file is really a .tar.gz file...
util.file_is_targz() {
	local file="$1"

	util.ensure_nonzero 'file'

	local magic_byte=
	if magic_byte="$(xxd -p -l 2 "$file")"; then
		if [ "$magic_byte" != '1f8b' ]; then
			return 1
		fi
	else
		return 1
	fi
}

# @description Get id of package we can use for printing
util.get_package_id() {
	local repo_type="$1"
	local url="$2"
	local site="$3"
	local package="$4"
	local version="$5"

	util.ensure_nonzero 'repo_type'
	util.ensure_nonzero 'url'
	util.ensure_nonzero 'site'
	util.ensure_nonzero 'package'
	util.ensure_nonzero 'version'

	if [ "$repo_type" = 'remote' ]; then
		REPLY="$site/$package@$version"
	elif [ "$repo_type" = 'local' ]; then
		REPLY="local/${url##*/}"
	fi
}

## Larger Utilities (have tests)

# @description Check if the package exists (either as a remote URL or file)
util.does_package_exist() {
	local repo_type="$1"
	local url="$2"

	util.ensure_nonzero 'repo_type'
	util.ensure_nonzero 'url'

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

	util.ensure_nonzero 'repo_type'
	util.ensure_nonzero 'url'
	util.ensure_nonzero 'site'
	util.ensure_nonzero 'package'

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
			print.warn "Could not automatically retrieve latest release for '$package' since '$site' is not supported. Falling back to retrieving latest commit"
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

	print-indent.die "Could not get latest release or commit for package '$package'"
}

util.get_package_info() {
	REPLY1=; REPLY2=; REPLY3=; REPLY4=; REPLY5=
	local input="$1"

	util.ensure_nonzero 'input'

	local regex1="^https?://"
	local regex2="^file://"
	local regex3="^git@" # TODO: continue with git@?
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
		local site= package=
		input="${input%.git}"

		if [[ "$input" == */*/* ]]; then
			IFS='/' read -r site package <<< "$input"
		elif [[ "$input" = */* ]]; then
			site="github.com"
			package="$input"
		else
			return 1
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

	util.ensure_nonzero 'site'
	util.ensure_nonzero 'package'
	util.ensure_nonzero 'ref'

	if [ "$site" = 'github.com' ]; then
		REPLY="https://github.com/$package/archive/refs/tags/$ref.tar.gz"
	elif [ "$site" = 'gitlab.com' ]; then
		REPLY="https://gitlab.com/$package/-/archive/$ref/${package#*/}-$ref.tar.gz"
	else
		print.die "Could not construct the location of the package tarball since '$site' is not supported"
	fi
}

# TODO: check command line arguments --force, etc.
util.show_help() {
	cat <<"EOF"
Basalt:
  The rock-solid Bash package manager

Usage:
  basalt [--help|--version]
  basalt <local-subcommand> [args...]
  basalt global <global-subcommand> [args...]

Local subcommands:
  init
    Creates a new Basalt package in the current directory

  add <package>
    Adds a dependency to the current local project

  upgrade <package>
    Upgrades a dependency for the current local project

  remove [--force] <package>
    Removes a dependency from the current local project

  install
    Resolves and installs all dependencies for the current local
    project

  list [--fetch] [--format=<simple>] [package...]
    Lists particular dependencies for the current local project

Global subcommands:
  init <shell>
    Prints shell code that must be evaluated during shell
    initialization for the proper functioning of Basalt

  add <package>
    Installs a global package

  upgrade <package>
    Upgrades a global package

  remove [--force] <package>
    Uninstalls a global package

  list [--fetch] [--format=<simple>] [package...]
    List all installed packages or just the specified ones

Examples:
  basalt add tj/git-extras
  basalt add github.com/tj/git-extras
  basalt add https://github.com/tj/git-extras
  basalt add git@github.com:tj/git-extras
  basalt add hyperupcall/bash-args --branch=main
  basalt add hyperupcall/bash-args@v0.6.1 # out of date
EOF
}
