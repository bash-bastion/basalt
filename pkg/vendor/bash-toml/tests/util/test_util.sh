# shellcheck shell=bash

test_util.bash_toml.has_key() {
	if test_util.object_has_key 'TOML' "$1"; then
		return 0
	else
		return 1
	fi
}

test_util.bash_toml.key_has_value() {
	if test_util.object_has_key_and_value 'TOML' "$1" "$2"; then
		return 0
	else
		return 1
	fi
}

# TODO: Doesn't work when '$2' is 'key'?
test_util.object_has_key() {
	local obj_name="$1"
	local key="$2"

	# TODO: test if is an associative array

	local -n obj="$obj_name"
	if [ ${obj["$key"]+abc} ]; then
		return 0
	else
		return 1
	fi
}

test_util.object_has_key_and_value() {
	local obj_name="$1"
	local key="$2"
	local value="$3"

	# TODO: test if is an associative array

	if ! test_util.object_has_key "$obj_name" "$key"; then
		return 1
	fi

	local -n obj="$obj_name"
	if [ "${obj["$key"]}" = "$value" ]; then
		return 0
	else
		return 1
	fi
}
