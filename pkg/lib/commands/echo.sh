# shellcheck shell=bash

basher-echo() {
	eval "printf \"%s\" \$$1"
}
