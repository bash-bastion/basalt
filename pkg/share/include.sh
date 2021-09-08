# shellcheck shell=sh

include() {
	package="$1"
	file="$2"

	if [ -z "$BASALT_GLOBAL_CELLAR" ]; then
		printf "%s\n" "Error: 'BASALT_GLOBAL_CELLAR' is empty" >&2
		return 1
	fi

	if [ -z "$package" ] || [ -z "$file" ]; then
		printf "%s\n" "Error: Usage: include <package> <file>" >&2
		return 1
	fi

	if [ ! -d "$BASALT_GLOBAL_CELLAR/packages/$package" ]; then
		printf "%s\n" "Error: Package '$package' not installed" >&2
		return 1
	fi

	if [ ! -f "$BASALT_GLOBAL_CELLAR/packages/$package/$file" ]; then
		printf "%s\n" "Error: File '$BASALT_GLOBAL_CELLAR/packages/$package/$file' not found" >&2
		return 1
	fi

	. "$BASALT_GLOBAL_CELLAR/packages/$package/$file" >&2

	unset package file
}
