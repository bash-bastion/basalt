#!/usr/bin/env bats

load './util/init.sh'

@test "local creates basalt.toml" {
	run basalt init

	assert_success
	assert [ -f 'basalt.toml' ]
}

# TODO
# @test "exports BASALT_REPO_SOURCE" {
# 	unset BASALT_REPO_SOURCE
# 	eval "$(BASALT_REPO_SOURCE=/lol basalt global init bash)"

# 	assert_success
# 	assert [ "$BASALT_REPO_SOURCE" = '/lol' ]
# 	assert test_util.is_exported 'BASALT_REPO_SOURCE'
# }

# @test "exports BASALT_CELLAR" {
# 	unset BASALT_CELLAR
# 	eval "$(BASALT_CELLAR=/lol basalt global init bash)"

# 	assert_success
# 	assert [ "$BASALT_CELLAR" = '/lol' ]
# 	assert test_util.is_exported 'BASALT_CELLAR'
# }

@test "sources basalt-load for Bash" {
	BASALT_REPO_SOURCE="$BASALT_TEST_REPO_ROOT/../source"

	eval "$(basalt global init bash)"

	assert_success
	assert [ "$(type -t basalt-load)" = 'function' ]
}


@test "sources basalt-load for Zsh" {
	BASALT_REPO_SOURCE="$BASALT_TEST_REPO_ROOT/../source"

	eval "$(basalt global init zsh)"

	assert_success
	assert [ "$(type -t basalt-load)" = 'function' ]
}

@test "fails if shell is not available" {
	run basalt global init fakesh

	assert_failure
	assert_line -p "Shell 'fakesh' is not a valid shell"
}

@test "bash completion works" {
	! command -v _basalt

	BASALT_REPO_SOURCE="$BASALT_TEST_REPO_ROOT/../source"

	eval "$(basalt global init bash)"

	assert command -v _basalt
}

@test "is fish compatible" {
	if ! command -v fish &>/dev/null; then
		skip "Command 'fish' not in PATH"
	fi

	HOME= XDG_DATA_HOME= XDG_STATE_HOME= XDG_CONFIG_HOME= run fish -Pc '. (basalt init fish | psub)'

	assert_success
}

@test "is sh-compatible" {
	run eval "$(basalt global init - sh)"
	assert_success
}
