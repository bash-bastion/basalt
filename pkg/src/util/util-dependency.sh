# shellcheck shell=bash

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

	pkgutil.get_package_info "$dependency"
	local url2="$REPLY2"

	local line=
	while IFS= read -r line || [ -n "$line" ]; do
		if [ -z "$input" ]; then
			continue
		fi

		pkgutil.get_package_info "$line"
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

	pkgutil.get_allinfo "$dependency"
	local _pkg_fsslug="$REPLY5"

	local -a arr=()
	if util.text_dependency_is_installed "$text_file" "$dependency"; then
		local line=
		while IFS= read -r line || [ -n "$line" ]; do
			pkgutil.get_package_info "$line"
			local url1="$REPLY2"

			pkgutil.get_package_info "$dependency"
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

	rm -rf "$BASALT_GLOBAL_DATA_DIR/store/packages/$_pkg_fsslug"*
	if [ "$flag_force" = 'yes' ]; then
		rm -rf "$BASALT_GLOBAL_DATA_DIR/store/tarballs/$_pkg_fsslug"*
	fi
}


# TODO: remove this
# @description If any version of a text dependency is installed
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
