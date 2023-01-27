# shellcheck shell=bash

load './util/init.sh'

@test "Add works" {
	run basalt global add 'hyperupcall/bash-object@v0.6.3'

	assert_success
	assert [ "$(<"$BASALT_GLOBAL_DATA_DIR/global/dependencies")" = 'https://github.com/hyperupcall/bash-object@v0.6.3' ]
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/hyperupcall/bash-object@v0.6.3.tar.gz"
	assert_dir_exist "$BASALT_GLOBAL_DATA_DIR/store/packages/github.com/hyperupcall/bash-object@v0.6.3"
}

@test "Add works twice" {
	basalt global add 'hyperupcall/bash-object@v0.6.3'

	run basalt global add 'hyperupcall/bash-args@v0.8.1'
	assert_success
	assert [ "$(<"$BASALT_GLOBAL_DATA_DIR/global/dependencies")" = $'https://github.com/hyperupcall/bash-object@v0.6.3\nhttps://github.com/hyperupcall/bash-args@v0.8.1' ]
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/hyperupcall/bash-object@v0.6.3.tar.gz"
	assert_dir_exist "$BASALT_GLOBAL_DATA_DIR/store/packages/github.com/hyperupcall/bash-object@v0.6.3"
}

@test "Remove works" {
	basalt global add 'hyperupcall/bash-object@v0.6.3'

	run basalt global remove 'hyperupcall/bash-object'
	assert_success
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/hyperupcall/bash-object@v0.6.3.tar.gz"
	assert_dir_not_exist "$BASALT_GLOBAL_DATA_DIR/store/packages/github.com/hyperupcall/bash-object@v0.6.3"
}

@test "Remove works with multiple repositories" {
	skip

	basalt global add 'hyperupcall/bash-object@v0.6.3'
	basalt global add 'hyperupcall/bash-args@v0.8.1'

	run basalt global remove 'hyperupcall/bash-object'
	assert_success
	assert [ "$(<"$BASALT_GLOBAL_DATA_DIR/global/dependencies")" = 'https://github.com/hyperupcall/bash-args@v0.8.1' ]
	assert_file_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/hyperupcall/bash-object@v0.6.3.tar.gz"
	assert_dir_not_exist "$BASALT_GLOBAL_DATA_DIR/store/packages/github.com/hyperupcall/bash-object@v0.6.3"
}

@test "Remove force works" {
	basalt global add 'hyperupcall/bash-object@v0.6.3'

	run basalt global remove --force 'hyperupcall/bash-object'
	assert_success
	assert_file_not_exist "$BASALT_GLOBAL_DATA_DIR/store/tarballs/github.com/hyperupcall/bash-object@v0.6.3.tar.gz"
	assert_dir_not_exist "$BASALT_GLOBAL_DATA_DIR/store/packages/github.com/hyperupcall/bash-object@v0.6.3"
}
