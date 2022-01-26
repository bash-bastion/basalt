# shellcheck shell=bash

load './util/init.sh'

@test "Succeeds on local absolute path" {
	mkdir -p subpkg
	cat > 'subpkg/basalt.toml' <<-"EOF"
	[package]
	type = 'bash'
	name = 'subpkg'
	EOF

	cat > 'basalt.toml' <<-"EOF"
	dependencies = ['file://./subpkg']
	EOF

	basalt install

	pkgutil.get_localpkg_info 'file://./subpkg'
	local pkg_id="$REPLY3"

	assert [ -d "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id" ]
	cmp -s './subpkg/basalt.toml' "$BASALT_GLOBAL_DATA_DIR/store/packages/$pkg_id/basalt.toml"
}
