# shellcheck shell=bash

# @file util.sh
# @brief Temporary utility functions. These will be here until replaced by a better implementation

# @description Retrieve a string key from a toml file
util.get_toml_string() {
	REPLY=
	local toml_file="$1"
	local key_name="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_name'

	if [ ! -f "$toml_file" ]; then
		print.internal_die "File '$toml_file' not found"
	fi

	local grep_line=
	while IFS= read -r line; do
		if [[ $line == *"$key_name"*=* ]]; then
			grep_line="$line"
			break
		fi
	done < "$toml_file"

	# If the grep_line is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grep_line" ]; then
		REPLY=''
		return 1
	fi

	local regex="[ \t]*${key_name}[ \t]*=[ \t]*['\"](.*)['\"]"
	if [[ $grep_line =~ $regex ]]; then
		REPLY="${BASH_REMATCH[1]}"
	else
		# This should not happen due to the '[[ $line == *"$key_name"*=* ]]' check above
		print.internal_die "Could not find key '$key_name' in file '$toml_file'"
	fi
}

# @description Retrieve an array key from a Toml file
util.get_toml_array() {
	unset REPLIES; declare -ga REPLIES=()
	local toml_file="$1"
	local key_name="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_name'

	if [ ! -f "$toml_file" ]; then
		print.internal_die "File '$toml_file' does not exist"
	fi

	local grep_line=
	while IFS= read -r line; do
		if [[ $line == *"$key_name"*=* ]]; then
			grep_line="$line"
			break
		fi
	done < "$toml_file"

	# If the grep_line is empty, it means the key wasn't found, and we continue to
	# the next configuration file. We need the intermediary grep check because
	# we don't want to set the value to an empty string if it the config key is
	# not found in the file (since piping to sed would result in something indistinguishable
	# from setting the key to an empty string value)
	if [ -z "$grep_line" ]; then
		REPLY=''
		return 1
	fi

	local regex="[ \t]*${key_name}[ \t]*=[ \t]*\[[ \t]*(.*)[ \t]*\]"
	if [[ "$grep_line" =~ $regex ]]; then
		local -r arrayString="${BASH_REMATCH[1]}"

		IFS=',' read -ra REPLIES <<< "$arrayString"
		for i in "${!REPLIES[@]}"; do
			# Treat all Toml strings the same; there shouldn't be
			# any escape characters anyways
			local regex="[ \t]*['\"](.*)['\"]"
			if [[ ${REPLIES[$i]} =~ $regex ]]; then
				REPLIES[$i]="${BASH_REMATCH[1]}"
			else
				print.die "Key '$key_name' in file '$toml_file' is not valid"
				return 2
			fi
		done
	else
		print.die "Key '$key_name' in file '$toml_file' must be set to an array that spans one line"
		return 2
	fi
}

# Append an element to a Toml array in a file
util.toml_add_dependency() {
	local toml_file="$1"
	local key_value="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_value'

	if [ ! -f "$toml_file" ]; then
		print.internal_die "File '$toml_file' does not exist"
	fi

	if util.get_toml_array "$toml_file" 'dependencies'; then
		local name=
		for name in "${REPLIES[@]}"; do
			if [ "${name%@*}" = "${key_value%@*}" ]; then
				print.indent-yellow 'Warning' "A version of '${name%@*}' is already installed. Skipping"
				return
			fi
		done
		unset name

		if ((${#REPLIES[@]} == 0)); then
			mv "$toml_file" "$toml_file.bak"
			sed -e "s,\([ \t]*dependencies[ \t]*=[ \t]*.*\)\],\1'${key_value}']," "$toml_file.bak" > "$toml_file"
			rm "$toml_file.bak"
		else
			mv "$toml_file" "$toml_file.bak"
			sed -e "s,\([ \t]*dependencies[ \t]*=[ \t]*.*\(['\"]\)\),\1\, \2${key_value}\2," "$toml_file.bak" > "$toml_file"
			rm "$toml_file.bak"
		fi
	else
		print.die "Key 'dependencies' not found in file '$toml_file'"
	fi
}

util.toml_remove_dependency() {
	local toml_file="$1"
	local key_value="$2"

	ensure.nonzero 'toml_file'
	ensure.nonzero 'key_name'

	if [ ! -f "$toml_file" ]; then
		print.internal_die "File '$toml_file' does not exist"
	fi

	if util.get_toml_array "$toml_file" 'dependencies'; then
		local dependency_array=()
		local name=
		local does_exist='no'
		for name in "${REPLIES[@]}"; do
			if [ "${name%@*}" = "${key_value%@*}" ]; then
				does_exist='yes'
			else
				dependency_array+=("$name")
			fi
		done
		unset name

		if [ "$does_exist" != 'yes' ]; then
			print.indent-die "The package '$key_value' is not currently a dependency"
			return
		fi

		mv "$toml_file" "$toml_file.bak"
		while IFS= read -r line; do
			if [[ "$line" == *dependencies*=* ]]; then
				local new_line='dependencies = ['
				for dep in "${dependency_array[@]}"; do
					printf -v new_line "%s'%s', " "$new_line" "$dep"
				done
				unset dep

				new_line="${new_line%, }]"
				printf '%s\n' "$new_line"
			else
				printf '%s\n' "$line"
			fi
		done < "$toml_file.bak" > "$toml_file"
		rm "$toml_file.bak"
	else
		print.die "Key 'dependencies' not found in file '$toml_file'"
	fi
}

util.text_add_dependency() {
	local text_file="$1"
	local dependency="$2"

	ensure.nonzero 'text_file'
	ensure.nonzero 'dependency'

	mkdir -p "${text_file%/*}"
	touch "$text_file"

	local line=
	while IFS= read -r line; do
		if [ "${line%@*}" = "${dependency%@*}" ]; then
			print.indent-yellow 'Warning' "A version of '${line%@*}' is already installed. Skipping"
			return
		fi
	done < "$text_file"
	unset line

	printf '%s\n' "$dependency" >> "$text_file"
}
