# shellcheck shell=bash

load './util/init.sh'

@test "Succeeds on relative path" {
	skip

	test_util.init_app 'project-echo' 'subpkg'

	test_util.init_app 'project-foxtrot' '.' \
		$'[run]\ndependencies = [\'file://./subpkg\']'

	basalt install

	pkgutil.get_localpkg_info 'file://./subpkg'
	local pkg_id="$REPLY3"

	assert [ -d "./.basalt/packages/$pkg_id" ]
	assert [ -d "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id" ]
	cmp -s './subpkg/basalt.toml' "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id/basalt.toml"
}

@test "Succeeds on absolute path" {
	skip

	test_util.init_app 'project-echo' 'subpkg'

	test_util.init_app 'project-foxtrot' '.' \
		$'[run]\ndependencies = [\'file://'"$PWD/subpkg']"

	basalt install

	pkgutil.get_localpkg_info 'file://./subpkg'
	local pkg_id="$REPLY3"

	assert [ -d "./.basalt/packages/$pkg_id" ]
	assert [ -d "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id" ]
	cmp -s './subpkg/basalt.toml' "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id/basalt.toml"
}
