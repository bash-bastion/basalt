#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no binaries" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
}

@test "adds bins determined from package.sh" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="binn/exec1:binn/exec2.sh"' > 'package.sh'
		mkdir 'binn'
		touch 'binn/exec1'
		touch 'binn/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/$pkg/binn/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/$pkg/binn/exec2.sh" ]
}


@test "adds bins determined from package.sh (and not with heuristics)" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'BINS="ff/exec3"' > 'package.sh'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2'
		mkdir 'ff'
		touch 'ff/exec3'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec3)" = "$BPM_PACKAGES_PATH/$pkg/ff/exec3" ]
}

@test "adds bins determined from bpm.toml" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "weird_dir" ]' > 'bpm.toml'
		mkdir 'weird_dir'
		touch 'weird_dir/exec1'
		touch 'weird_dir/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/weird_dir/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2.sh")" = "$BPM_PACKAGES_PATH/$pkg/weird_dir/exec2.sh" ]
}

@test "adds bins determined from bpm.toml (and not heuristics)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'binDirs = [ "weird_dir" ]' > 'bpm.toml'
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2'
		mkdir 'weird_dir'
		touch 'weird_dir/exec3'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec3")" = "$BPM_PACKAGES_PATH/$pkg/weird_dir/exec3" ]
}

@test "adds bins determined with heuristics (bin directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
}

@test "adds bins determined with heuristics (root directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec1'
		touch 'exec2.sh'
		chmod +x 'exec1' 'exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2.sh")" = "$BPM_PACKAGES_PATH/$pkg/exec2.sh" ]
}

@test "does not add bins that are not executable in root directory)" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		touch 'exec1'
		touch 'exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec3" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec4.sh" ]
}

@test "doesn't link root bins if there is a bin folder" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		mkdir 'bin'
		touch 'bin/exec1'
		touch 'exec2'
		chmod +x 'exec2'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ ! -e "$(readlink "$BPM_INSTALL_BIN/exec2")" ]
}

@test "remove extensions if REMOVE_EXTENSION is true in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="true"' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_clone "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
}

# Backwards compatiblity
@test "does not remove extensions if REMOVE_EXTENSION is set in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION=' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_clone "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2.sh")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2" ]
}

@test "does not remove extensions if REMOVE_EXTENSION is false in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'REMOVE_EXTENSION="false"' > 'package.sh'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_clone "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink $BPM_INSTALL_BIN/exec1)" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink $BPM_INSTALL_BIN/exec2.sh)" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
}

@test "remove extensions if binRemoveExtensions is 'yes' in bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binRemoveExtensions = "yes"' > 'bpm.toml'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_clone "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
}

@test "do not remove extensions if binRemoveExtensions is 'no' in bpm.toml" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'binRemoveExtensions = "no"' > 'bpm.toml'
		mkdir bin
		touch 'bin/exec1'
		touch 'bin/exec2.sh'
	}; test_util.finish_pkg
	test_util.fake_clone "$pkg"

	run do-plumbing-link-bins "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec1")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec1" ]
	assert [ "$(readlink "$BPM_INSTALL_BIN/exec2.sh")" = "$BPM_PACKAGES_PATH/$pkg/bin/exec2.sh" ]
}

@test "does not symlink package itself as bin when linked with bpm link" {
	mkdir -p 'package' 'username/package2'

	# implicit call to do-plumbing-link-bins
	run do-link 'package' 'username/package2'

	assert_success
	assert [ ! -e "$BPM_PREFIX/bin/package" ]
	assert [ ! -e "$BPM_PREFIX/bin/package2" ]
}
