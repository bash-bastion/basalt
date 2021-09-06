# shellcheck shell=bash

do-plumbing-unlink-bins() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	abstract.bins 'unlink' "$pkg"
}
