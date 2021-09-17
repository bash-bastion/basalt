#!/usr/bin/env bats

load './util/init.sh'

@test "github works" {
	util.get_tarball_url 'github.com' 'hyperupcall/uwu' 'v0.1.0'

	assert [ "$REPLY" = 'https://github.com/hyperupcall/uwu/archive/refs/tags/v0.1.0.tar.gz' ]
}

@test "gitlab works" {
	util.get_tarball_url 'gitlab.com' 'hyperupcall/uwu' 'v0.1.0'

	assert [ "$REPLY" = 'https://gitlab.com/hyperupcall/uwu/-/archive/v0.1.0/uwu-v0.1.0.tar.gz' ]
}
