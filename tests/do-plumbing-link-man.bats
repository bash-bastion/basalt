#!/usr/bin/env bats

load 'util/init.sh'

@test "links each man page to install-man under correct subdirectory" {
	local package='username/package'

	create_package "$package"
	create_man username/package exec.1
	create_man username/package exec.2
	test_util.fake_clone "$package"

	run do-plumbing-link-man username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/username/package/man/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man2/exec.2")" = "$BPM_PACKAGES_PATH/username/package/man/exec.2" ]
}

@test "manual man dir links subdirs" {
	local package="username/package"

	test_util.setup_pkg "$package"; {
		echo 'manDirs = [ "a_dir" ]' > 'bpm.toml'
		# Leave a '_' suffix to directory to be extra flexible
		mkdir -p 'a_dir/man1_'
		touch 'a_dir/man1_/exec.1'

		mkdir -p 'a_dir/man5_'
		touch 'a_dir/man5_/execcfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$package/a_dir/man1_/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/execcfg.5")" = "$BPM_PACKAGES_PATH/$package/a_dir/man5_/execcfg.5" ]
}

@test "heuristic search links subdirs" {
	local package="username/package"

	test_util.setup_pkg "$package"; {
		# Leave a '_' suffix to directory to be extra flexible
		mkdir -p 'man/man1_'
		touch 'man/man1_/exec.1'

		mkdir -p 'man5_'
		touch 'man5_/execcfg.5'
	}; test_util.finish_pkg
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/exec.1")" = "$BPM_PACKAGES_PATH/$package/man/man1_/exec.1" ]
	assert [ "$(readlink "$BPM_INSTALL_MAN/man5/execcfg.5")" = "$BPM_PACKAGES_PATH/$package/man5_/execcfg.5" ]
}

@test "links mans from bpm.toml to prefix/man" {
	local package='username/package'

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
	mkdir 'weird_man'
	touch 'weird_man/prog.1'
	echo 'manDirs = [ "weird_man" ]' > 'bpm.toml'
	git add .
	git commit -m "Add man"
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	run do-plumbing-link-man "$package"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/prog.1")" = "$BPM_PACKAGES_PATH/$package/weird_man/prog.1" ]
}

@test "links each top-level man page to install-man under correct subdirectory" {
	local package="username/package"

	create_package username/package
	create.man_root 'prog.1'
	test_util.fake_clone "$package"

	run do-plumbing-link-man username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_MAN/man1/prog.1")" = "$BPM_PACKAGES_PATH/$package/prog.1" ]
}
