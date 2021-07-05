# shellcheck shell=bash

basher-complete() {
	case "$1" in
	package-path)
		basher-list
		;;
	uninstall)
		basher-list
		;;
	upgrade)
		basher-list
		;;
	esac
}
