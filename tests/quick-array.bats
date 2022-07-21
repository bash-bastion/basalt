#!/usr/bin/env bats

load './util/init.sh'

@test "Quick array properly fails" {
	run bash_toml.quick_array_get "$BASALT_PACKAGE_DIR/tests/testdata/array/file1.toml" \
		'badkey'

	assert_failure
}

@test "Quick array get" {
	for n in {1..7}; do
		bash_toml.quick_array_get "$BASALT_PACKAGE_DIR/tests/testdata/array/file1.toml" \
			"key0${n}"
		assert [ "${#REPLY[@]}" -eq 0 ]
	done
}


@test "Quick array get 2" {
	for m in {1..2}; do
		for n in {1..7}; do
			bash_toml.quick_array_get "$BASALT_PACKAGE_DIR/tests/testdata/array/file1.toml" \
				"key${m}${n}"
			assert [ "${#REPLY[@]}" -eq 1 ]
			assert [ -z "${REPLY[0]}" ]
		done
	done
}

@test "Quick array get 3" {
	for m in {3..10}; do
		for n in {1..7}; do
			bash_toml.quick_array_get "$BASALT_PACKAGE_DIR/tests/testdata/array/file1.toml" \
				"key${m}${n}"
			assert [ "${#REPLY[@]}" -eq 2 ]
			assert [ "${REPLY[0]}" = 'a' ]
			assert [ "${REPLY[1]}" = 'b' ]
		done
	done
}

@test "Quick array get multiline" {
	for n in {0..1}; do
		bash_toml.quick_array_get "$BASALT_PACKAGE_DIR/tests/testdata/array/file2.toml" \
			"key${n}"
		assert [ "${#REPLY[@]}" -eq 1 ]
		assert [ "${REPLY[0]}" = 'multiline' ]
	done
}
