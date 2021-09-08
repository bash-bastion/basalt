#!/usr/bin/env bats

load 'util/init.sh'

@test "properly removes each man page determined from heuristics" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'man'
		touch 'man/exec.1'
		touch 'man/exec.2'
		touch 'exec.3'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	run plumbing.unsymlink-mans "$site/$pkg"

	assert_success
	assert [ ! -e "$BASALT_INSTALL_MAN/man1/exec.1" ]
	assert [ ! -e "$BASALT_INSTALL_MAN/man2/exec.2" ]
	assert [ ! -e "$BASALT_INSTALL_MAN/man2/exec.3" ]
}

@test "properly removes each man page determined from manDir cfg" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'manDirs = [ "^_^" ]' > 'basalt.toml'
		mkdir '^_^'
		touch '^_^/exec.1'
		touch '^_^/exec.2'
	}; test_util.finish_pkg
	test_util.mock_add "$pkg"

	assert [ -f "$BASALT_INSTALL_MAN/man1/exec.1" ]

	run plumbing.unsymlink-mans "$site/$pkg"

	assert_success
	assert [ ! -e "$BASALT_INSTALL_MAN/man1/exec.1" ]
	assert [ ! -e "$BASALT_INSTALL_MAN/man2/exec.2" ]
}
