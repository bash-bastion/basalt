# shellcheck shell=bash

load './util/init.sh'

@test "Succeeds on relative path" {
	test_util.init_app 'project-echo' 'subpkg' \
		'_' \
		'_'

	test_util.init_app 'project-foxtrot' '.' \
		"dependencies = ['file://./subpkg']" \
		'_'

	basalt install

	pkgutil.get_localpkg_info 'file://./subpkg'
	local pkg_id="$REPLY3"

	assert [ -d "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id" ]
	cmp -s './subpkg/basalt.toml' "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id/basalt.toml"
}

@test "Succeeds on absolute path" {
	test_util.init_app 'project-echo' 'subpkg' \
		'_' \
		'_'

	test_util.init_app 'project-foxtrot' '.' \
		"dependencies = ['file://$PWD/subpkg']" \
		'_'

	basalt install

	pkgutil.get_localpkg_info 'file://./subpkg'
	local pkg_id="$REPLY3"

	assert [ -d "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id" ]
	cmp -s './subpkg/basalt.toml' "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id/basalt.toml"
}
