#!/usr/bin/env bats

load './util/init.sh'

@test "core.shotpt_push works" {
	shopt -u extglob

	core.shopt_push -s extglob

	assert [ "${#___global_shopt_stack___[@]}" = 2 ]
	assert [ ${___global_shopt_stack___[0]} = '-u' ]
	assert [ ${___global_shopt_stack___[1]} = 'extglob' ]
	assert shopt -q extglob

	core.shopt_pop
	assert [ "${#___global_shopt_stack___[@]}" = 0 ]
	refute shopt -q extglob
}

@test "core.shopt_push works 2" {
	shopt -u extglob
	shopt -u dotglob
	shopt -u failglob

	core.shopt_push -s extglob
	core.shopt_push -s dotglob
	core.shopt_push -s failglob

	assert shopt -q extglob
	assert shopt -q dotglob
	assert shopt -q failglob

	core.shopt_pop
	core.shopt_pop
	core.shopt_pop

	assert [ "${#___global_shopt_stack___[@]}" = 0 ]
	refute shopt -q extglob
	refute shopt -q dotglob
	refute shopt -q failglob
}
