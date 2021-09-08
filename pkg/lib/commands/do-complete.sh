# shellcheck shell=bash

do-complete() {
	# TODO ensure works
	case "$1" in
	list)
		do-list
		;;
	esac
}
