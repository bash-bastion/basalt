# shellcheck shell=bash

# @description Given an object hierarchy (ex. run.dependencies),
# get the full value of
bash_toml.util_line_is_part_of_array() {
	local -n __mode="$1"
	local key_location="$2"
	local key_name="$3"
	local line="$4"

	if [ "$__mode" = '--' ]; then
		return 1
	fi

	local regex1=$'^[ \t]*'"\[$key_location\]"
	local regex2=$'^[ \t]*'"[.*?]"$'[ \t]*'
	if [[ $line =~ $regex1 ]]; then
		__mode='matched-objhier'
		return 1
	elif [[ $line =~ $regex2 ]]; then
		__mode=''
	fi

	if [ "$__mode" = 'matched-objhier' ]; then
		local regex1=^$'[ \t]*'"$key_name"$'[ \t]*='
		if [[ $line =~ $regex1 ]]; then
			__mode='matched-all'
		fi
	fi

	if [ "$__mode" = 'matched-all' ]; then
		local regex2=$'[ \t]*\][ \t]*$'
		if [[ $line =~ $regex2 ]]; then
			__mode='--'
		fi

		return 0
	else
		return 1
	fi
}

bash_toml.util_line_is_part_of_object() {
	local -n __mode="$1"
	local key_location="$2"
	local line="$3"

	if [ "$__mode" = '--' ]; then
		return 1
	fi

	local regex1=$'^[ \t]*'"\[$key_location\]"
	local regex2=$'^\[run.shoptOptions\]'
	if [[ $line =~ $regex1 ]]; then
		__mode='matched-objhier'
		return 1
	elif [[ $line =~ $regex2 ]]; then
		__mode='--'
	fi

	if [ "$__mode" = 'matched-objhier' ]; then
		return 0
	else
		return 1
	fi
}

bash_toml.util_parse_array() {
	local -n __arr="$1"
	local str="$2"

	local i=0
	while IFS= read -rN1 char; do
		if [[ $char == '"' || $char == "'" ]]; then
			__arr+=($((i)))
		fi

		((++i))
	done <<< "$str"; unset -v char
	unset -v i
}

# @note Uses dynamically scoped 'REPLY'
bash_toml.util_iterate() {
	local -n __arr="$1"
	local handler="$2"

	local pre="${line:0:${__arr[0]}}"
	REPLY+=$pre

	local i
	for ((i = 0; i < ${#__arr[@]}; i = i + 2)); do
		local value_start=$((__arr[i] + 1))
		local value_end=$((__arr[i+1] - __arr[i] - 1))
		local post_start=$((__arr[i+1] + 1))
		local post_end=$((__arr[i+2] - __arr[i+1] - 1))
		if ((i == ${#__arr[@]} - 2)); then
			post_end="${#line}"
		fi

		local quote=\'
		local item_value="${line:$value_start:$value_end}"
		local post="${line:$post_start:$post_end}"

		local ret=0
		REPLY_INNER_CMD=
		"$handler" "$item_value" "$i" '__arr'
		if [ "$REPLY_INNER_CMD" = 'skip' ]; then
			REPLY="${REPLY%"${REPLY##*[![:space:]]}"}"
			continue
		elif [ "$REPLY_INNER_CMD" = 'add' ]; then
			REPLY+=${quote}${item_value}${quote}${post}
			ret=1
		elif [ "$REPLY_INNER_CMD" = 'replace' ]; then
			REPLY+=${quote}${REPLY_INNER_VALUE}${quote}${post}
			ret=1
		elif [ "$REPLY_INNER_CMD" = 'append' ]; then
			REPLY+=${quote}${item_value}${quote}
			REPLY+=,\ ${quote}${REPLY_INNER_VALUE}${quote}${post}
			ret=1
		fi
	done; unset -v i

	return "${ret:-0}"
}

# @description Initialize bash-toml
bash_toml.util_init() {
	declare -gA BASH_TOML_ERRORS=(
		[INTERNAL_ERROR]='Internal error'
		[NOT_IMPLEMENTED]='TOML feature has not been implemented'
		[UNEXPECTED_BRANCH]='This branch was not supposed to be activated. Please submit an issue'
		[UNICODE_INVALID]='The resulting unicode code point was invalid'
		[KEY_ABSENT]='Key does not have a value'
		[UNEXPECTED_EOF]='Unexpected end of line'
		[UNEXPECTED_NEWLINE]='Unexpected newline'
		[UNEXPECTED_CHARACTER]='An unexpected character was encountered' # Generalization of any of the following errors
		[KEY_INVALID]='The key is not valid'
		[VALUE_INVALID]='The value could not be parsed'
		[VALUE_STRING_INVALID]='The string value could not be parsed'
	)

	declare -a BASH_TOKEN_HISTORY=()
}

# @description Appends to token history for improved error insight
bash_toml.util_token_history_add() {
	local str=
	printf -v str '%s' "$mode ($char) at $PARSER_LINE_NUMBER:$PARSER_COLUMN_NUMBER"

	BASH_TOKEN_HISTORY+=("$str")

	if [ -n "${DEBUG_BASH_TOML+x}" ]; then
		if [ -n "${BATS_RUN_TMPDIR+x}" ]; then
			printf '%s\n' "$str" >&3
		else
			printf '%s\n' "$str"
		fi
	fi
}

bash_toml.parse_fail() {
	local error_key="$1"
	local error_context="$2"

	if [ -z "$error_context" ]; then
		error_context="<empty>"
	fi

	local error_message="${BASH_TOML_ERRORS["$error_key"]}"

	local error_output=
	printf -v error_output 'Failed to parse toml:
  -> code: %s
  -> message: %s
  -> context: %s
  -> trace:' "$error_key" "$error_message" "$error_context"

	for history_item in "${BASH_TOKEN_HISTORY[@]}"; do
		printf -v error_output '%s\n    - %s' "$error_output" "$history_item"
	done

	if [ "$TOML_MANUAL_ERROR" = yes ]; then
		TOML_ERROR="$error_output"
		return 1
	else
		printf '%s' "$error_output"
		exit 1
	fi
}

bash_toml.error() {
	printf '%s\n' "Error: $1" >&2
}
