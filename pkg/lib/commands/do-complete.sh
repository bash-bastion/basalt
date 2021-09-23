# shellcheck shell=bash

do-complete() {
	case "$1" in
	list)
		do-list
		;;
	esac
}
