# shellcheck shell=bash

bpm-echo() {
	eval "printf \"%s\" \$$1"
}
