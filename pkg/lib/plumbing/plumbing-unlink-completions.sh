# shellcheck shell=bash

do-plumbing-unlink-completions() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	abstract.completions 'unlink' "$pkg"
}
