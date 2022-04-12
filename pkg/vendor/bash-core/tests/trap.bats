#!/usr/bin/env bats

load './util/init.sh'

# Note that the array appending of these core.trap-* functions are tested. The actual
# execution of the functions on the signal are bit tested. There seems to be a limitation
# of Bats that prevents this from working

# Additionally, the '${___global_trap_table___[nokey]}' is there to ensure that the
# ___global_trap_table___ is an associative array. If that variable is not an associative
# array, indexing with 'nokey' still yields the value of the (string) variable (no error
# will be thrown). Now that 'core.init' is automatically called when the array is not
# defined (to be an associative array), these checks are unecessary (yet, they still exist)

@test "core.trap_add fails when function is not supplied" {
	run core.trap_add '' 'USR1'

	assert_failure
	assert_output -p "First argument must not be empty"
}

@test "core.trap_add fails when signal is not supplied" {
	run core.trap_add 'function' 

	assert_failure
	assert_output -p "Must specify at least one signal"
}

@test "core.trap_add fails when signal is empty" {
	run core.trap_add 'function' ''

	assert_failure
	assert_output -p "Signal must not be an empty string"
}

@test "core.trap_add fails when function specified does not exist" {
	run core.trap_add 'nonexistent' 'USR1'

	assert_failure
	assert_output -p "Function 'nonexistent' is not defined"
}

@test "core.trap_add fails when number is given for signal" {
	run core.trap_add 'function' '0'

	assert_failure
	assert_output -p "Passing numbers for the signal specs is prohibited"
}

@test "core.trap_add adds trap function properly" {
	somefunction() { :; }
	core.trap_add 'somefunction' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}

@test "core.trap_add adds function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction\x1Csomefunction2' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction\x1Csomefunction2' ]
}

@test "core.trap_add adds function properly 3" {
	somefunction() { :; }
	core.trap_add 'somefunction' 'USR1' 'USR2'
	
	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR2]}" = $'\x1Csomefunction' ]
}

@test "core.trap_remove fails when function is not supplied" {
	run core.trap_remove '' 'USR1'

	assert_failure
	assert_output -p "First argument must not be empty"
}

@test "core.trap_remove fails when signal is not supplied" {
	run core.trap_remove 'function' 

	assert_failure
	assert_output -p "Must specify at least one signal"
}

@test "core.trap_remove fails when signal is empty" {
	run core.trap_remove 'function' ''

	assert_failure
	assert_output -p "Signal must not be an empty string"
}

@test "core.trap_remove fails when function specified does not exist" {
	run core.trap_remove 'nonexistent' 'USR1'

	assert_failure
	assert_output -p "Function 'nonexistent' is not defined"
}

@test "core.trap_remove removes trap function properly" {
	somefunction() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[USR1]}" = '' ]
}

@test "core.trap_remove removes trap function properly 2" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction2' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction2' ]
}

@test "core.trap_add removes function properly 3" {
	somefunction() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction' 'USR2'
	core.trap_remove 'somefunction' 'USR1' 'USR2'

	[ "${___global_trap_table___[USR1]}" = '' ]
	[ "${___global_trap_table___[USR2]}" = '' ]
}

@test "core.trap_remove removes trap function properly 4" {
	somefunction() { :; }
	somefunction2() { :; }
	core.trap_add 'somefunction' 'USR1'
	core.trap_add 'somefunction2' 'USR1'
	core.trap_remove 'somefunction2' 'USR1'

	[ "${___global_trap_table___[nokey]}" != $'\x1Csomefunction' ]
	[ "${___global_trap_table___[USR1]}" = $'\x1Csomefunction' ]
}


