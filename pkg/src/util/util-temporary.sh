# shellcheck shell=bash

# @file util.sh
# @brief Temporary utility functions. These will be here until replaced by a better implementation

# Append an element to a Toml array in a file
util.toml_add_dependency() {
	local toml_file="$1"
	local key_value="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_value'

	if [ ! -f "$toml_file" ]; then
		print.fatal "File '$toml_file' does not exist"
	fi

	bash_toml.quick_array_append "$toml_file" 'run.dependencies' "$key_value"
}

util.toml_remove_dependency() {
	local toml_file="$1"
	local key_value="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_value'

	if [ ! -f "$toml_file" ]; then
		print.fatal "File '$toml_file' does not exist"
	fi

	bash_toml.quick_array_remove "$toml_file" 'run.dependencies' "$key_value"
}

util.text_add_dependency() {
	local text_file="$1"
	local dependency="$2"

	ensure.nonzero 'text_file'
	ensure.nonzero 'dependency'

	mkdir -p "${text_file%/*}"
	touch "$text_file"

	util.get_package_info "$dependency"
	local url2="$REPLY2"

	local line=
	while IFS= read -r line || [ -n "$line" ]; do
		if [ -z "$input" ]; then
			continue
		fi

		util.get_package_info "$line"
		local url1="$REPLY2"

		if [ "$url1" = "$url2" ]; then
			print.warn "A version of '${line%@*}' is already installed. Skipping"
		fi
	done < "$text_file"; unset line

	printf '%s\n' "$dependency" >> "$text_file"
}

util.text_remove_dependency() {
	local text_file="$1"
	local dependency="$2"
	local flag_force="$3"

	ensure.nonzero 'text_file'
	ensure.nonzero 'dependency'
	ensure.nonzero 'flag_force'

	util.get_package_info "$dependency"
	local repo_type="$REPLY1" url="$REPLY2" site="$REPLY3" package="$REPLY4" version="$REPLY5"

	util.get_package_id --allow-empty-version "$repo_type" "$url" "$site" "$package" "$version"
	local package_id="$REPLY"

	local -a arr=()
	if util.text_dependency_is_installed "$text_file" "$dependency"; then
		local line=
		while IFS= read -r line || [ -n "$line" ]; do
			util.get_package_info "$line"
			local url1="$REPLY2"

			util.get_package_info "$dependency"
			local url2="$REPLY2"

			if [ "$url1" != "$url2" ]; then
				arr+=("$line")
			fi
		done < "$text_file"

		printf "%s\n" "${arr[@]}" > "$text_file"
	else
		if [ "$flag_force" = 'no' ]; then
			print.die "Dependency '${dependency%@*}' is not installed. Skipping"
		fi
	fi

	rm -rf "$BASALT_GLOBAL_DATA_DIR/store/packages/$package_id"*
	if [ "$flag_force" = 'yes' ]; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$package_id"*
	fi
}
