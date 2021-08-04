# shellcheck shell=bash

do-echo() {
	util.setup_mode

	eval "printf '%s' \$$1"
}
