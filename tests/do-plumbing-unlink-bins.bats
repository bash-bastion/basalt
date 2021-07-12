#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no binaries" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
}

@test "removes bins determined from package.sh" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="somebin/exec1:somebin/exec2.sh"' > 'package.sh'
		mkdir 'somebin'
		touch 'somebin/exec1'
		touch 'somebin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "removes bins determined from bpm.toml" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "somebin" ]' > 'bpm.toml'
		mkdir 'somebin'
		touch 'somebin/exec1'
		touch 'somebin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "removes bins determined from heuristics (bin directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "removes bins determined from heuristics (root directory)" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec1'
		touch 'exec2.sh'
		chmod +x 'exec1' 'exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "properly removes binary when REMOVE_EXTENSION is true" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="true"' > 'package.sh'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2" ]
}

# Even if 'REMOVE_EXTENSION' is set, it is still not true, so we
# do not  actually remove the extension. i.e. preserve backwards compatibility
@test "properly removes binary when REMOVE_EXTENSION is set" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION=""' > 'package.sh'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "properly removes binary when REMOVE_EXTENSION is false" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="false"' > 'package.sh'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]

	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "bpm.toml has presidence over package.sh unlink bins" {
	local site='github.com'
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="otherbin/e1:otherbin/e2.sh"' > 'package.sh'
		mkdir 'otherbin'
		touch 'otherbin/e1'
		touch 'otherbin/e2.sh'

		echo 'binDirs = [ "somebin" ]' > 'bpm.toml'
		mkdir 'somebin'
		touch 'somebin/exec1'
		touch 'somebin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_add "$pkg"

	assert [ ! -L "$BPM_INSTALL_BIN/e1" ]
	assert [ ! -L "$BPM_INSTALL_BIN/e2.sh" ]
	assert [ -L "$BPM_INSTALL_BIN/exec1" ]
	assert [ -L "$BPM_INSTALL_BIN/exec2.sh" ]


	run do-plumbing-unlink-bins "$site/$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}
