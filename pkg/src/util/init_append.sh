# shellcheck shell=bash

bash_toml.init_key_string() {
	BASH_TOML_KEY_STRING="$1"
}

bash_toml.append_key_string() {
	BASH_TOML_KEY_STRING+="$1"
}

bash_toml.init_value_string() {
	BASH_TOML_KEY_VALUE_STRING=
}

bash_toml.append_value_string() {
	BASH_TOML_KEY_VALUE_STRING+="$1"
}
