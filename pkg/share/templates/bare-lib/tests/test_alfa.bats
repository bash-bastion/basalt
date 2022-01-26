#!/usr/bin/env bats

load './util/init.sh'

@test "Outputs 'foxxy!'" {
	run TEMPLATE_SLUG.fn

	[ "$status" -eq 0 ]
	[ "$output" = "foxxy!" ]
}
