#!/usr/bin/env bats

load 'util/init.sh'

@test "removes each binary in BINS config from the install bin" {
	local package="username/package"

	create_package username/package
	create_package_exec username/package exec1
	create_package_exec username/package exec2.sh
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins 'bpm-local/package'

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

# @test "remove bpm.toml bin" {
# 	local package="username/package"

# 	test_util.setup_pkg "$package"; {
# 		echo 'manDirs = [ "a_dir" ]' > 'bpm.toml'
# 		# Leave a '_' suffix to directory to be extra flexible
# 		mkdir -p 'a_dir/man1_'
# 		touch 'a_dir/man1_/exec.1'

# 		mkdir -p 'a_dir/man5_'
# 		touch 'a_dir/man5_/execcfg.5'
# 	}; test_util.finish_pkg
# 	test_util.fake_clone "$package"

# 	run do-plumbing-unlink-bins "$package"

# 	assert_success
# 	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$package/a_dir/man1_/exec.1" ]
# 	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/execcfg.5")" = "$BPM_PACKAGES_PATH/$package/a_dir/man5_/execcfg.5" ]
# }

@test "removes each binary from the install bin" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins 'bpm-local/package'

	assert_success
	assert [ ! -e "$BPM_INSTALL_BIN/exec1" ]
	assert [ ! -e "$BPM_INSTALL_BIN/exec2.sh" ]
}

@test "removes root binaries from the install bin" {
	local package="username/package"

	create_package username/package
	create_root_exec username/package exec3
	create_root_exec username/package exec4.sh
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins bpm-local/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec3)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec4.sh)" ]
}

@test "does not fail if there are no binaries" {
	local package="username/package"

	create_package username/package
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins bpm-local/package

	assert_success
}

@test "removes binary when REMOVE_EXTENSION is true" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package true
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins bpm-local/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2)" ]
}

@test "removes binary when REMOVE_EXTENSION is false" {
	local package="username/package"

	create_package username/package
	create_exec username/package exec1
	create_exec username/package exec2.sh
	set_remove_extension username/package false
	do-link "$BPM_ORIGIN_DIR/$package"

	run do-plumbing-unlink-bins bpm-local/package

	assert_success
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec1)" ]
	assert [ ! -e "$(readlink $BPM_INSTALL_BIN/exec2.sh)" ]
}
