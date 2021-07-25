# shellcheck shell=bash

do-complete() {
	case "$1" in
	package-path)
		do-list
		;;
	remove)
		do-list
		;;
	upgrade)
		do-list
		;;
	esac
}
