# shellcheck shell=bash

do-plumbing-link-bins() {
	local id="$1"
	ensure.non_zero 'id' "$id"

	abstract.bins 'link' "$id"
}
