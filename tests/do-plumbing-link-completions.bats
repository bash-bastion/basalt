#!/usr/bin/env bats

load 'util/init.sh'

@test "links bash completions from package.sh to prefix/completions" {
	create_package username/package
	create_bash_completions username/package comp.bash

	# TODO: remove mock-command plumbing-clone?
	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/comp.bash")" = "$BPM_PACKAGES_PATH/username/package/completions/comp.bash" ]
}

@test "links bash completions from ./?(contrib/)completion?(s)" {
	local -i i=1
	for completionDir in completion completions contrib/completion contrib/completions; do

		local package="username/package$i"
		create_package "$package"

		# Manually add completion
		cd "$BPM_ORIGIN_DIR/$package"
		mkdir -p "$completionDir"
		touch "$completionDir/c.bash"
		touch "$completionDir/c2.sh"
		git add .
		git commit -m "Add completions"
		cd "$BPM_CWD"

		# Manually install
		mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
		ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

		run bpm-plumbing-link-completions "$package"

		assert_success
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c.bash")" = "$BPM_PACKAGES_PATH/$package/$completionDir/c.bash" ]
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/bash/c2.sh")" = "$BPM_PACKAGES_PATH/$package/$completionDir/c2.sh" ]

		(( ++i ))
	done
}

@test "don't link bash from './?(contrib/)completion?(s)' when BASH_COMPLETIONS is specified in package.sh" {
	local package="username/package"
	create_package "$package"

	cd "$BPM_ORIGIN_DIR/$package"
	mkdir completions
	touch completions/prog.bash
	echo "BASH_COMPLETIONS=" >| package.sh
	cd "$BPM_CWD"

	# Manually install
	mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
	ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

	run bpm-plumbing-link-completions "$package"

	! [ -f "$BPM_INSTALL_COMPLETIONS/bash/prof.bash" ]
}

@test "do link bash from './?(contrib/)completion?(s)' when ZSH_COMPLETIONS is specified in package.sh" {
	local package="username/package"
	create_package "$package"

	cd "$BPM_ORIGIN_DIR/$package"
	mkdir completions
	touch completions/prog.bash
	echo "ZSH_COMPLETIONS=" >| package.sh
	cd "$BPM_CWD"

	# Manually install
	mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
	ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

	run bpm-plumbing-link-completions "$package"

	[ -f "$BPM_INSTALL_COMPLETIONS/bash/prog.bash" ]
}

@test "links zsh compsys completions to prefix/completions" {
	create_package username/package
	create_zsh_compsys_completions username/package _exec
	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_COMPLETIONS/zsh/compsys/_exec)" = "$BPM_PACKAGES_PATH/username/package/completions/_exec" ]
}

@test "links zsh compctl completions to prefix/completions" {
	create_package username/package
	create_zsh_compctl_completions username/package exec
	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-completions username/package

	assert_success
	assert [ "$(readlink $BPM_INSTALL_COMPLETIONS/zsh/compctl/exec)" = "$BPM_PACKAGES_PATH/username/package/completions/exec" ]
}

@test "links zsh completions from ./?(contrib/)completion?(s)" {
	local -i i=1
	for completionDir in completion completions contrib/completion contrib/completions; do

		local package="username/package$i"
		create_package "$package"

		# Manually add completion
		cd "$BPM_ORIGIN_DIR/$package"
		mkdir -p "$completionDir"
		touch "$completionDir/c.zsh"
		echo "#compdef" >| "$completionDir/c2.zsh"
		git add .
		git commit -m "Add completions"
		cd "$BPM_CWD"

		# Manually install
		mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
		ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

		run bpm-plumbing-link-completions "$package"

		assert_success
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compsys/c2.zsh")" = "$BPM_PACKAGES_PATH/$package/$completionDir/c2.zsh" ]
		assert [ "$(readlink "$BPM_INSTALL_COMPLETIONS/zsh/compctl/c.zsh")" = "$BPM_PACKAGES_PATH/$package/$completionDir/c.zsh" ]

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
	cd "$BPM_CWD"

	# Manually install
	mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
	ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

	run bpm-plumbing-link-completions "$package"

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
	cd "$BPM_CWD"

	# Manually install
	mkdir -p "$BPM_PACKAGES_PATH/${package%%/*}"
	ln -s "$BPM_ORIGIN_DIR/$package" "$BPM_PACKAGES_PATH/$package"

	run bpm-plumbing-link-completions "$package"

	assert_success
	[ -f "$BPM_INSTALL_COMPLETIONS/zsh/compctl/prog.zsh" ]
}


@test "does not fail if package doesn't have any completions" {
	create_package username/package
	test_util.mock_command plumbing-clone
	bpm-plumbing-clone false site username package

	run bpm-plumbing-link-completions username/package

	assert_success
}
