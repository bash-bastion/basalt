# shellcheck shell=bash

do-release() {
	util.init_local

	local flag_yes='no'
	local -a args=()
	local arg=
	for arg; do case $arg in
	-y|--yes)
		flag_yes='yes'
		;;
	-*)
		bprint.die "Flag '$arg' not recognized"
		;;
	*)
		args+=("$arg")
		;;
	esac done; unset -v arg

	if ((${#args[@]} > 1)); then
		bprint.die "The only argument must be the new version string"
	fi

	# Exit if working tree is not empty
	local git_output=
	if ! git_output="$(git status --porcelain)"; then
		bprint.die "Could not run 'git status --porcelain'"
	fi
	if [ -n "$git_output" ]; then
		bprint.die "The working tree must be empty (including untracked files)"
	fi
	unset git_output

	local previous_version_string=
	local version_string="${args[0]}"

	if util.get_toml_string "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'version'; then
		previous_version_string="$REPLY"
	else
		bprint.die "To use 'basalt version', a you must have a 'version' field set to at least an empty string"
	fi

	if [ -z "$version_string" ]; then
		printf '%s\n' "Old version: $previous_version_string"
		printf '%s' 'New version: '
		read -rep "New version: " -i "$previous_version_string"
		version_string="$REPLY"
	else
		if [ "$flag_yes" != yes ]; then
			printf '%s\n' "Changing: $previous_version_string -> $version_string"

			read -rep "Are you sure (y/n): "
			if [[ $REPLY != @(y|yes) ]]; then
				bprint.info "Cancelling version change"
				return
			fi
		fi
	fi

	if [ "$previous_version_string" = "$version_string" ]; then
		bprint.info "Previous version same as new version. Exiting without making any changes"
		return
	fi

	if [ -z "$version_string" ]; then
		bprint.info "Version string blank. Exiting without making any changes"
		return
	fi

	# TODO: after self-bootstrap, add additional validation checks
	if [[ $version_string =~ [,\'\"\\] ]]; then
		bprint.die "Version string cannot have commas, backslashes, single quotes, or double quotes"
	fi

	local toml_file="$BASALT_LOCAL_PROJECT_DIR/basalt.toml"
	mv "$toml_file" "$toml_file.bak"
	sed -e "s,\([ \t]*version[ \t]*=[ \t]*['\"]\)\(.*\)\(['\"].*\),\1${version_string}\3," "$toml_file.bak" > "$toml_file"
	rm "$toml_file.bak"

	if util.get_toml_string "$BASALT_LOCAL_PROJECT_DIR/basalt.toml" 'version'; then
		if [ "$REPLY" != "$version_string" ]; then
			bprint.die "Failed to properly substitute version with sed"
		fi
	else
		bprint.die "Expected a value for field 'version'"
	fi

	bprint.info "running: git add \"\$BASALT_LOCAL_PROJECT_DIR/basalt.toml\""
	if ! git add "$toml_file"; then
		bprint.die "Failed to 'git add'"
	fi

	bprint.info "running: git commit -m v$version_string"
	if ! git commit -qm "v$version_string"; then
		bprint.die "Failed to 'git commit'"
	fi

	bprint.info "running: git tag -a -m v$version_string v$version_string"
	if ! git tag -a -m "v$version_string" "v$version_string"; then
		bprint.die "Failed to 'git tag'"
	fi
}
