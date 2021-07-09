#!/usr/bin/env bats

load 'util/init.sh'

@test "does not fail if there are no binaries" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		:
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
}

@test "adds bash completions determined from package.sh" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		mkdir 'completions'
		touch 'completions/comp.bash'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$pkg/completions/comp.bash" ]
}


@test "adds bash completions determined from package.sh (and not from heuristics)" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo "BASH_COMPLETIONS=" > 'package.sh'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg

	run do-plumbing-link-completions "$pkg"

	! [ -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined from bpm.toml" {
	local pkg='username/package'

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'weird_completions'
		touch 'weird_completions/comp.bash'
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/$pkg/weird_completions/comp.bash" ]
}

@test "adds bash completions determined from bpm.toml (and not from heuristics)" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {
		echo 'completionDirs = [ "weird_completions" ]' > 'bpm.toml'
		mkdir 'completions'
		touch 'completions/prof.bash'
	}; test_util.finish_pkg

	run do-plumbing-link-completions "$pkg"

	! [ -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "adds bash completions determined with heuristics ./?(contrib/)completion?(s)" {
	local pkg="username/package$i"

	test_util.setup_pkg "$pkg"; {
		mkdir -p ./{contrib/,}completion{,s}
		touch "completion/c1.bash"
		touch "completions/c2.bash"
		touch "contrib/completion/c3.bash"
		touch "contrib/completions/c4.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$pkg"

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c1.bash")" = "$BPM_PACKAGES_PATH/$pkg/completion/c1.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c2.bash")" = "$BPM_PACKAGES_PATH/$pkg/completions/c2.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c3.bash")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completion/c3.bash" ]
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c4.bash")" = "$BPM_PACKAGES_PATH/$pkg/contrib/completions/c4.bash" ]
}

@test "adds bash completions determined from heuristics when when ZSH_COMPLETIONS is specified in package.sh" {
	local pkg="username/package"

	test_util.setup_pkg "$pkg"; {'
		echo "ZSH_COMPLETIONS="' > 'package.sh'
		mkdir 'completion'
		touch "completion/prog.bash"
	}; test_util.finish_pkg
	test_util.fake_install "$pkg"

	run do-plumbing-link-completions "$package"

	[ -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "links zsh compsys completions to prefix/completions" {
	local package="username/package"

	create_package username/package
	create_zsh_compsys_completions username/package _exec
	test_util.fake_clone "$package"

	run do-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec)" = "$BPM_PACKAGES_PATH/username/package/completions/_exec" ]
}

@test "links zsh compctl completions to prefix/completions" {
	local package="username/package"

	create_package username/package
	create_zsh_compctl_completions username/package exec
	test_util.fake_clone "$package"

	run do-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_COMPLETIONS/zsh/compctl/exec)" = "$BPM_PACKAGES_PATH/username/package/completions/exec" ]
}

@test "links zsh completions from ./?(contrib/)completion?(s)" {
	local -i i=1
	for completion_dir in completion completions contrib/completion contrib/completions; do
		local package="username/package$i"

		create_package "$package"
		cd "$BPM_ORIGIN_DIR/$package"
		mkdir -p "$completion_dir"
		touch "$completion_dir/c.zsh"
		echo "#compdef" >| "$completion_dir/c2.zsh"
		git add .
		git commit -m "Add completions"
		cd "$BPM_CWD"
		test_util.fake_clone "$package"

		run do-plumbing-link-completions "$package"

		assert_success
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/c2.zsh")" = "$BPM_PACKAGES_PATH/$package/$completion_dir/c2.zsh" ]
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c.zsh")" = "$BPM_PACKAGES_PATH/$package/$completion_dir/c.zsh" ]

		(( ++i ))
	done
}

@test "don't link bash from './?(contrib/)completion?(s)' when ZSH_COMPLETIONS is specified in package.sh" {
	local package="username/package"

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
	mkdir completions
	touch completions/prog.zsh
	echo "ZSH_COMPLETIONS=" >| package.sh
	git add .
	git commit -m 'Add package.sh'
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	run do-plumbing-link-completions "$package"

	assert_success
	! [ -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prof.zsh" ]
	! [ -f "$BPM_INSTALL_COMPLETIONS/zsh/compsys/prof.zsh" ]
}

@test "do link zsh from './?(contrib/)completion?(s)' when BASH_COMPLETIONS is specified in package.sh" {
	local package="username/package"

	create_package "$package"
	cd "$BPM_ORIGIN_DIR/$package"
	mkdir completions
	touch completions/prog.zsh
	echo "BASH_COMPLETIONS=" >| package.sh
	git add .
	git commit -m 'Add package.sh'
	cd "$BPM_CWD"
	test_util.fake_clone "$package"

	run do-plumbing-link-completions "$package"

	assert_success
	[ -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
}


@test "does not fail if package doesn't have any completions" {
	local package="username/package"

	create_package username/package
	test_util.fake_clone "$package"

	run do-plumbing-link-completions username/package

	assert_success
}
