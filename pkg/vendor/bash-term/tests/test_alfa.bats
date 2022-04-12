#!/usr/bin/env bats

load './util/init.sh'

@test "Outputs 'woofers!'" {
	run bash-tty

	[ "$status" -eq 0 ]
	[ "$output" = "woofers!" ]
}
