# shellcheck shell=bash

do-echo() {
	eval "printf \"%s\" \$$1"
}
