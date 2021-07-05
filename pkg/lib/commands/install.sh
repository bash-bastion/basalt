# shellcheck shell=bash

basher-install() {
	local use_ssh="false"

	case "$1" in
		--ssh)
			use_ssh="true"
			shift
		;;
	esac

	local site= user= repository= ref=
	util.parse_package_full "$1"
	IFS=':' read -r site user repository ref <<< "$REPLY"

	basher-plumbing-clone "$use_ssh" "$site" "$user/$repository" $ref
	basher-plumbing-deps "$user/$repository"
	basher-plumbing-link-bins "$user/$repository"
	basher-plumbing-link-completions "$user/$repository"
	basher-plumbing-link-completions "$user/$repository"
}
