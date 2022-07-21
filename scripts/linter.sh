# shellcheck shell=bash

file='./pkg/lib/cmd/bash-bash_toml.sh'
grep -n -B0 -A1 -e 'bash_toml.parse_fail' "$file" \
	| grep -vP '(^[0-9]*:|^--$)' \
	| awk '
	BEGIN {
		FS="-"
	}
	{
		if ($2 !~ /return 1/) {
			str=sub(/^[ \t]+/, "", $2)
			printf "%s\n", "No return statement found on line `" $1 "`"
			printf "%s\n\n", "  --> `" $2 "`"
		}
	}
'
