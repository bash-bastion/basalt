# shellcheck shell=bash

load './util/init.sh'

@test "Works with local packages" {
	mkdir -p 'subpkg/src'
	cat > 'subpkg/src/file.sh' <<-"EOF"
	subpkg_fn() {
		printf '%s\n' 'I am here!'
	}
	EOF
	cat > 'subpkg/basalt.toml' <<-"EOF"
	[package]
	type = 'bash'
	name = 'subpkg'

	sourceDirs = ['src']
	EOF
	( cd subpkg && basalt install )


	cat > 'basalt.toml' <<-"EOF"
	dependencies = ['file://./subpkg']
	EOF

	basalt install

	BASALT_PACKAGE_DIR="$PWD" REPO_ROOT="$REPO_ROOT" bash -c "
	source \"$REPO_ROOT/pkg/src/public/basalt-global.sh\"
	source \"$REPO_ROOT/pkg/src/public/basalt-package.sh\"

	basalt.package-load
	subpkg_fn
	"
}
