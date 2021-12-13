# shellcheck shell=bash

load './util/init.sh'

@test "Outputs 'Woof!'" {
	run main.file
	[ "$status" -eq 0 ]
	[ "$output" = "Woof!" ]
}
