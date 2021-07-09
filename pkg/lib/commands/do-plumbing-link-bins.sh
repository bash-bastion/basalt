# shellcheck shell=bash

do-plumbing-link-bins() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	abstract.bins 'link' "$pkg"
}
