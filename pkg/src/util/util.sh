# shellcheck shell=bash

std.find_parent() {
	# shellcheck disable=SC1007
	local op="$1"
	local file="$2"
	
	if REPLY=$(
		# shellcheck disable=SC1072,SC1073,SC1009
		while [ ! "$op" "$file" ] && [ "$PWD" != / ]; do
			if ! cd ..; then
				exit 1
			fi
		done
		if [ "$PWD" = / ]; then
			exit 0
		fi
		printf '%s' "$PWD"
	); then :; else
		panic 'Failed to cd'
	fi
}

std.private.should_print_color() {
	local fd="$1"

	if [[ ${NO_COLOR+x} || "$TERM" = 'dumb' ]]; then
		return 1
	fi

	if [ -t "$fd" ]; then
		return 0
	fi

	return 1
}