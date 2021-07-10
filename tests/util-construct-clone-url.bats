#!/usr/bin/env bats

load 'util/init.sh'


@test "fails on no arguments" {
	run util.construct_clone_url

	assert_failure
	assert_line -p "Must supply a repository"
}

@test "parses with full https url" {
	util.construct_clone_url 'https://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full http url" {
	util.construct_clone_url 'http://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'http://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full https url with .git ending" {
	util.construct_clone_url 'https://gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full http url with .git ending" {
	util.construct_clone_url 'http://gitlab.com/eankeen/proj.git'

	assert [ "$REPLY1" = 'http://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with full ssh url" {
	util.construct_clone_url 'git@gitlab.com:eankeen/proj.git'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain" {
	util.construct_clone_url 'gitlab.com/eankeen/proj'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain and ref" {
	util.construct_clone_url 'gitlab.com/eankeen/proj@v0.1.0'

	assert [ "$REPLY1" = 'https://gitlab.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.1.0' ]
}

@test "parses with package and domain with ssh" {
	util.construct_clone_url 'gitlab.com/eankeen/proj' 'yes'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and domain and ref with ssh" {
	util.construct_clone_url 'gitlab.com/eankeen/proj@v0.1.0' 'yes'

	assert [ "$REPLY1" = 'git@gitlab.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'gitlab.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.1.0' ]
}

@test "parses with package" {
	util.construct_clone_url 'eankeen/proj'

	assert [ "$REPLY1" = 'https://github.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package and ref" {
	util.construct_clone_url 'eankeen/proj@v0.2.0'

	assert [ "$REPLY1" = 'https://github.com/eankeen/proj.git' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}

@test "parses with package with ssh" {
	util.construct_clone_url 'eankeen/proj' 'yes'

	assert [ "$REPLY1" = 'git@github.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = '' ]
}

@test "parses with package with ssh and ref" {
	util.construct_clone_url 'eankeen/proj@v0.2.0' 'yes'

	assert [ "$REPLY1" = 'git@github.com:eankeen/proj' ]
	assert [ "$REPLY2" = 'github.com' ]
	assert [ "$REPLY3" = 'eankeen/proj' ]
	assert [ "$REPLY4" = 'v0.2.0' ]
}
