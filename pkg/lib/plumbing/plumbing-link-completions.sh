# shellcheck shell=bash

do-plumbing-link-completions() {
	local pkg="$1"
	ensure.non_zero 'pkg' "$pkg"

	abstract.completions 'link' "$pkg"
}
