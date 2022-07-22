# shellcheck shell=bash

pkgutil.get_localpkg_info() {
	unset -v REPLY{1,2}
	REPLY1= REPLY2=

	local url=$1

	url="${url#file://}"
	url="${url%/}"

	util.get_full_path "$url" # Prevent collisions on relative paths
	local pkg_path="$REPLY"
	local pkg_name="${url##*/}"
	local pkg_id=
	if ! pkg_id=$(printf '%s' "$pkg_path" | md5sum); then
		print.fatal "Failed to execute md5sum successfully"
	fi
	pkg_id="${pkg_id%% *}"
	pkg_id="local/${pkg_name}_$pkg_id"

	if [ "${pkg_path:0:1}" = '/' ]; then
		pkg_path="$pkg_path"
	elif [ "${pkg_path:0:2}" = './' ]; then
		pkg_path="$BASALT_LOCAL_PROJECT_DIR/$pkg_path"
	else
		print.fatal "Specified local path '$pkg_path' not recognized"
	fi

	REPLY1=$pkg_path
	REPLY2=$pkg_name
	REPLY3=$pkg_id
}


# @description Get the latest package version
pkgutil.get_latest_package_version() {
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
			if latest_package_version=$(
				curl -LsS -H "authorization: Bearer $GITHUB_TOKEN" "https://api.github.com/repos/$package/releases/latest" \
					| awk -F '"' '{ if($2 == "tag_name") print $4 }'
			) && [[ "$latest_package_version" == v* ]]; then
				REPLY="$latest_package_version"
				return
			fi
		else
			print.warn "Could not automatically retrieve latest release for '$package' since '$site' is not supported. Falling back to retrieving latest commit"
		fi
	fi

	# If there is not an official release, then just get the latest commit of the project
	local latest_commit=
	if latest_commit=$(
		git ls-remote "$url" | awk '{ if($2 == "HEAD") print $1 }'
	); then
		REPLY="$latest_commit"
		return
	fi

	print.die "Could not get latest release or commit for package '$package'"
}

# @description Get id of package we can use for printing
pkgutil.get_package_id() {
	local flag_allow_empty_version='no' # Allow for version to be empty
	for arg; do case $arg in
		--allow-empty-version) flag_allow_empty_version='yes'; if ! shift; then core.panic 'Failed to shift'; fi ;;
		-*) print.fatal "Flag '$arg' not recognized" ;;
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

# @description Get pacakge info
pkgutil.get_package_info() {
	unset REPLY{1,2,3,4,5}
	REPLY1=; REPLY2=; REPLY3=; REPLY4=; REPLY5=
	local input="$1"
	ensure.nonzero 'input'

	local regex1="^https?://"
	local regex2="^file://"
	if [[ "$input" =~ $regex1 ]]; then
		local site= package=

		input="${input#http?(s)://}"
		ref="${input##*@}"
		if [ "$ref" = "$input" ]; then ref=; fi
		input="${input%@*}"
		input="${input%.git}"

		IFS='/' read -r site package <<< "$input"

		REPLY1='remote'
		REPLY2="https://$input"
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
	else
		local site= package= ref=
		input="${input%.git}"

		if [[ "$input" == */*/* ]]; then
			IFS='/' read -r site package <<< "$input"
		elif [[ "$input" = */* ]]; then
			site="github.com"
			package="$input"
		else
			print.die "String '$input' does not look like a package"
		fi

		if [[ "$package" == *@* ]]; then
			IFS='@' read -r package ref <<< "$package"
		fi

		REPLY1='remote'
		REPLY2="https://$site/$package"
		REPLY3="$site"
		REPLY4="$package"
		REPLY5="$ref"
	fi

	if [ -z "$ref" ]; then
		# TODO: print name of package this is originating from
		print.die "Specified packages must have a version. For example, change 'https://github.com/hyperupcall/bash-toml' to 'https://github.com/hyperupcall/bash-object@v0.10.21'"
	fi
}
