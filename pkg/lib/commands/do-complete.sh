# shellcheck shell=bash

bpm-complete() {
	case "$1" in
	package-path)
		bpm-list
		;;
	uninstall)
		bpm-list
		;;
	upgrade)
		bpm-list
		;;
	esac
}
