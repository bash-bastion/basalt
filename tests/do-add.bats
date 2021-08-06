#!/usr/bin/env bats

load 'util/init.sh'

@test "fails when no packages are specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add

	assert_failure
	assert_line -n 0 -p "At least one package must be supplied"
}

@test "fails when the remote repository is owned by a user with username 'local'" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add 'local/pkg'

	assert_failure
	assert_line -n 0 -p  "Cannot install packages owned by username 'local' because that conflicts with linked packages"
}

@test "fails when input is an absolute path to a directory" {
	local site='github.com'
	local pkg='username/main'

	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	test_util.create_package "$pkg"
	run do-add "$BPM_ORIGIN_DIR/$pkg"

	assert_failure
	assert_line -p "Identifier '$BPM_ORIGIN_DIR/$pkg' is a directory, not a package"
}

@test "executes install steps in right order" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package

	assert_success
	assert_line -n 0 -p "Adding 'username/package'"
	assert_line -n 1 'do-plumbing-clone https://github.com/username/package.git github.com/username/package  '
	assert_line -n 2 'do-plumbing-add-deps github.com/username/package'
	assert_line -n 3 'do-plumbing-link-bins github.com/username/package'
	assert_line -n 4 'do-plumbing-link-completions github.com/username/package'
	assert_line -n 5 'do-plumbing-link-man github.com/username/package'
}

@test "executes install steps in right order for multiple packages" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package username2/package2

	assert_success
	assert_line -n 0 -p "Adding 'username/package'"
	assert_line -n 1 'do-plumbing-clone https://github.com/username/package.git github.com/username/package  '
	assert_line -n 2 'do-plumbing-add-deps github.com/username/package'
	assert_line -n 3 'do-plumbing-link-bins github.com/username/package'
	assert_line -n 4 'do-plumbing-link-completions github.com/username/package'
	assert_line -n 5 'do-plumbing-link-man github.com/username/package'
	assert_line -n 6 -p "Adding 'username2/package2'"
	assert_line -n 7 'do-plumbing-clone https://github.com/username2/package2.git github.com/username2/package2  '
	assert_line -n 8 'do-plumbing-add-deps github.com/username2/package2'
	assert_line -n 9 'do-plumbing-link-bins github.com/username2/package2'
	assert_line -n 10 'do-plumbing-link-completions github.com/username2/package2'
	assert_line -n 11 'do-plumbing-link-man github.com/username2/package2'
}


@test "uses longhand (https) site to clone from, if specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add https://gitlab.com/username/package

	assert_success
	assert_line "do-plumbing-clone https://gitlab.com/username/package.git gitlab.com/username/package  "
}

@test "uses longhand (http) site to clone from, if specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add http://gitlab.com/username/package

	assert_success
	assert_line "do-plumbing-clone http://gitlab.com/username/package.git gitlab.com/username/package  "
}

@test "uses shorthand site to clone from, if specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add site/username/package

	assert_success
	assert_line "do-plumbing-clone https://site/username/package.git site/username/package  "
}

@test "uses GitHub as default site, if not specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package

	assert_success
	assert_line "do-plumbing-clone https://github.com/username/package.git github.com/username/package  "
}

@test "uses ssh protocol, when specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add --ssh username/package

	assert_success
	assert_line "do-plumbing-clone git@github.com:username/package github.com/username/package  "
}

@test "uses ssh protocol, when specified (at end)" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package --ssh

	assert_success
	assert_line "do-plumbing-clone git@github.com:username/package github.com/username/package  "
}

@test "uses ssh protocol raw, when specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add git@github.com:username/package

	assert_success
	assert_line "do-plumbing-clone git@github.com:username/package github.com/username/package  "
}

@test "uses custom version, when specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package@v1.2.3

	assert_success
	assert_line "do-plumbing-clone https://github.com/username/package.git github.com/username/package v1.2.3 "
}

@test "does not use custom version, when not specified" {
	test_util.stub_command do-plumbing-clone
	test_util.stub_command do-plumbing-add-deps
	test_util.stub_command do-plumbing-link-bins
	test_util.stub_command do-plumbing-link-completions
	test_util.stub_command do-plumbing-link-man

	run do-add username/package@

	assert_success
	assert_line "do-plumbing-clone https://github.com/username/package.git github.com/username/package  "
}


@test "--all works" {
	local site='github.com'
	local pkg="user/project"
	local pkg2="user/project2"

	test_util.create_package "$pkg"
	test_util.create_package "$pkg2"

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg', 'file://$BPM_ORIGIN_DIR/$pkg2' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success

	assert [ -d "./bpm_packages/packages/$site/$pkg/.git" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg2/.git" ]
}

@test "--all works with transitive dependencies" {
	local site='github.com'
	local pkg="user/project"
	local pkg2="user/project2"
	local pkg3="user/project3"

	test_util.create_package "$pkg"
	test_util.create_package "$pkg2"
	test_util.create_package "$pkg3"
	cd "$BPM_ORIGIN_DIR/$pkg2"
	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg3' ]" > 'bpm.toml'
	git add .
	git commit -m 'Add bpm.toml'
	cd "$BATS_TEST_TMPDIR"

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg', 'file://$BPM_ORIGIN_DIR/$pkg2' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success
	assert [ -d "./bpm_packages/packages/$site/$pkg/.git" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg2/.git" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg2/bpm_packages/packages/$site/$pkg3/.git" ]
}

@test "--all works with annotated ref" {
	local site='github.com'
	local pkg1="user/project"

	test_util.create_package "$pkg1"
	cd "$BPM_ORIGIN_DIR/$pkg1"
	git commit --allow-empty -m 'v0.1.0'
	git tag -a 'v0.1.0' -m 'Version: v0.1.0'
	cd "$BATS_TEST_TMPDIR"

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg1@v0.1.0' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success
	assert [ -d "./bpm_packages/packages/$site/$pkg1" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg1/.git" ]
	assert [ "$(git -C "./bpm_packages/packages/$site/$pkg1" describe --exact-match --tags)" = "v0.1.0" ]
}

@test "--all works with non-annotated ref" {
	local site='github.com'
	local pkg1="user/project"

	test_util.create_package "$pkg1"
	cd "$BPM_ORIGIN_DIR/$pkg1"
	git commit --allow-empty -m 'v0.1.0'
	git tag 'v0.1.0' -m 'Version: v0.1.0'
	cd "$BATS_TEST_TMPDIR"

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg1@v0.1.0' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success
	assert [ -d "./bpm_packages/packages/$site/$pkg1" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg1/.git" ]
	assert [ "$(git -C "./bpm_packages/packages/$site/$pkg1" describe --exact-match --tags)" = "v0.1.0" ]
}

@test "--all prints warning when no dependencies are specified in bpm.toml" {
	touch 'bpm.toml'

	BPM_MODE='local' run do-add --all

	assert_success
	assert_line -p "No dependencies specified in 'dependencies' key"
	refute_line -p "Installing"
}

@test "--all errors when a package is specified as argument" {
	touch 'bpm.toml'

	BPM_MODE='local' run do-add --all pkg

	assert_failure
	assert_line -p "No packages may be supplied when using '--all'"
}

@test "--all errors in global mode" {
	run do-add --all

	assert_failure
	assert_line -p "Cannot pass '--all' without a 'bpm.toml' file"
}

@test "--all works if some are already installed" {
	local site='github.com'
	local pkg1='user/project'
	local pkg2='user/project2'

	test_util.create_package "$pkg1"
	test_util.create_package "$pkg2"

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg1' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success

	echo "dependencies = [ 'file://$BPM_ORIGIN_DIR/$pkg1', 'file://$BPM_ORIGIN_DIR/$pkg2' ]" > 'bpm.toml'
	BPM_MODE='local' run do-add --all

	assert_success
	assert [ -d "./bpm_packages/packages/$site/$pkg1" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg1/.git" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg2" ]
	assert [ -d "./bpm_packages/packages/$site/$pkg2/.git" ]
}

@test "fails if in local mode" {
	local site='github.com'
	local pkg1='user/project'

	touch 'bpm.toml'

	test_util.create_package "$pkg1"

	BPM_MODE='local' run do-add "$pkg1"

	assert_failure
	assert_line -p "Cannot specify individual packages for subcommand 'add' in local projects. Please edit your 'bpm.toml' and use either 'add --all' or 'remove --all'"
}
