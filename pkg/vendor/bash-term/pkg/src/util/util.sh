# shellcheck shell=bash

term.util.may_set_print() {
	:
}

term.util.may_print() {
	if [[ -v flag_print ]]; then
		# shellcheck disable=SC2059
		printf "$REPLY"
		unset -v REPLY
	fi
}
