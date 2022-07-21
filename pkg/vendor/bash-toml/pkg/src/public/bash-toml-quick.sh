# shellcheck shell=bash

bash_toml.quick_string_get() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_name="$2"

	if [ ! -f "$toml_file" ]; then
		bash_toml.error "File '$toml_file' not found"
		return 1
	fi

	local regex=$'^[ \t]*'${key_name}$'[ \t]*=[ \t]*[\047"](.*)[\047\"]'
	local grep_line=
	while IFS= read -r line || [ -n "$line" ]; do
		if [[ $line =~ $regex ]]; then
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

	if [[ $grep_line =~ $regex ]]; then
		REPLY="${BASH_REMATCH[1]}"
	else
		# This should not happen due to the '[[ $line == *"$key_name"*=* ]]' check above
		bash_toml.error "Could not find key '$key_name' in file '$toml_file'"
		return 1
	fi
}

bash_toml.quick_string_set() {
	:
}

bash_toml.quick_array_metamodify() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_location="$2"
	local handler_fn="$3"

	# shellcheck disable=SC2034,SC1007
	local state=''
	while IFS= read -r line || [ -n "$line" ]; do
		if bash_toml.util_line_is_part_of_array 'state' "${key_location%.*}" "${key_location##*.}" "$line"; then
			local regex="^\[.*?\]"
			if [[ $line =~ $regex ]]; then :; else
				local regex="['\"]"
				if [[ $line =~ $regex ]]; then :; else
					REPLY+=$line
				fi
			fi

			local -a points=()
			bash_toml.util_parse_array 'points' "$line"
			bash_toml.util_iterate 'points' "$handler_fn"

			REPLY+=$'\n'
		else
			REPLY+=$line$'\n'
		fi
	done < "$toml_file"; unset -v line
}

bash_toml.quick_array_get() {
	unset -v REPLY_OUTER; declare -g REPLY_OUTER=()
	local toml_file="$1"
	local key_location="$2"

	handler() {
		local item_value="$1"

		REPLY_OUTER+=("$item_value")
	}
	bash_toml.quick_array_metamodify "$toml_file" "$key_location" 'handler'

	unset -v REPLY
	declare -g REPLY=("${REPLY_OUTER[@]}")
	unset -v REPLY_OUTER
}

bash_toml.quick_array_append() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_location="$2"
	local new_value="$3"

	local has_already_appended='no'
	handler() {
		local item_value="$1"
		local iteration_i="$2"
		local -n __points="$3"

		if ((iteration_i == ${#__points[@]} - 2)); then
			if [ "$has_already_appended" = 'no' ]; then
				REPLY_INNER_CMD='append'
				REPLY_INNER_VALUE="$new_value"
				has_already_appended='yes'
			else
				REPLY_INNER_CMD='add'
			fi
		else
			REPLY_INNER_CMD='add'
		fi
	}
	bash_toml.quick_array_metamodify "$toml_file" "$key_location" 'handler'
}

bash_toml.quick_array_remove() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_location="$2"
	local specified_value="$3"

	handler() {
		local item_value="$1"

		if [ "$item_value" = "$specified_value" ]; then
			REPLY_INNER_CMD='skip'
		else
			REPLY_INNER_CMD='add'
		fi
	}
	bash_toml.quick_array_metamodify "$toml_file" "$key_location" 'handler'
}

bash_toml.quick_array_replace() {
	unset -v REPLY; REPLY=
	local toml_file="$1"
	local key_location="$2"
	local old_value="$3"
	local new_value="$4"

	handler() {
		local item_value="$1"

		if [ "$item_value" = "$old_value" ]; then
			REPLY_INNER_CMD='replace'
			REPLY_INNER_VALUE="$new_value"
		else
			REPLY_INNER_CMD='add'
		fi
	}
	bash_toml.quick_array_metamodify "$toml_file" "$key_location" 'handler'
}

bash_toml.quick_object_get() {
	unset -v REPLY; declare -gA REPLY=()
	local toml_file="$1"
	local key_location="$2"

	# shellcheck disable=SC2034,SC1007
	local state=''
	while IFS= read -r line || [ -n "$line" ]; do
		if bash_toml.util_line_is_part_of_object 'state' "$key_location" "$line"; then
			local regex=$'[ \t]*(.*?[^ \t])[ \t]*=[ \t]*[\'"](.*?[^ \t])[\'"]'
			if [[ $line =~ $regex ]]; then
				local key="${BASH_REMATCH[1]}"
				local value="${BASH_REMATCH[2]}"

				REPLY["$key"]="$value"
			fi
		fi
	done < "$toml_file"; unset -v line
}
