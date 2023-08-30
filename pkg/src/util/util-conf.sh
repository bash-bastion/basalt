# shellcheck shell=bash

util.conf_read() {
	declare -g REPLY_{TYPE,NAME,NAMESPACE,VERSION,AUTHOR,DESC}=
	declare -ga REPLY_{DEPENDENCIES,BINDIRS,SOURCEDIRS,BUILTINDIRS,COMPILATIONDIRS,MANDIRS}=
	declare -gA REPLY_{ENV,SETOPTIONS,SHOPTOPTIONS}=

	local file="$1"
	local current_section=

	local key= value=
	while IFS='= ' read -r key value; do
		case $current_section in
		package)
			case $key in
				type)
					REPLY_TYPE=$value
					;;
				name)
					REPLY_NAME=$value
					;;
			esac
			;;
		run)
			case $key in
				a)
				;;
			esac
			;;
		*)
			;;
		esac
		printf '%s\n' "$key: $value"
	done < "$file"; unset -v key value
}
