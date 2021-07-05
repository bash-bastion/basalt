# shellcheck shell=sh

include() {
	local package="$1"
	local file="$2"

	if [ -z "$package" ] || [ -z "$file" ]; then
		echo "Usage: include <package> <file>" >&2
		return 1
	fi

	if [ ! -e "$NEOBASHER_PREFIX/packages/$package" ]; then
		echo "Package not installed: $package" >&2
		return 1
	fi

	if [ -e "$NEOBASHER_PREFIX/packages/$package/$file" ]; then
		. "$NEOBASHER_PREFIX/packages/$package/$file" >&2
	else
		echo "File not found: $NEOBASHER_PREFIX/packages/$package/$file" >&2
		return 1
	fi
}
