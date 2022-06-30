# shellcheck shell=bash

pkgutil.get_localpkg_info() {
	unset -v REPLY{1,2}
	REPLY1= REPLY2=

	local url=$1

	url="${url#file://}"
	url="${url%/}"

	util.get_full_path "$url" # Prevent collisions on relative paths
	local pkg_path="$REPLY"
	local pkg_name="${url##*/}"
	local pkg_id=
	if ! pkg_id=$(printf '%s' "$pkg_path" | md5sum); then
		print.fatal "Failed to execute md5sum successfully"
	fi
	pkg_id="${pkg_id%% *}"
	pkg_id="local/${pkg_name}_$pkg_id"

	if [ "${pkg_path:0:1}" = '/' ]; then
		pkg_path="$pkg_path"
	elif [ "${pkg_path:0:2}" = './' ]; then
		pkg_path="$BASALT_LOCAL_PROJECT_DIR/$pkg_path"
	else
		print.fatal "Specified local path '$pkg_path' not recognized"
	fi

	REPLY1=$pkg_path
	REPLY2=$pkg_name
	REPLY3=$pkg_id
}
