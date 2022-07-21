#!/usr/bin/env bats

load './util/init.sh'

@test "quick string get" {
	for tens in {0..1}; do
		for ones in {1..7}; do
			bash_toml.quick_string_get "$BASALT_PACKAGE_DIR/tests/testdata/string/file1.toml" \
				"key${tens}${ones}"
			assert [ "$REPLY" = "value${ones}" ]
		done
	done
}
