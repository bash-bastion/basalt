# shellcheck shell=bash

do-plumbing-unlink-man() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	abstract.mans 'unlink' "$pkg"
}
