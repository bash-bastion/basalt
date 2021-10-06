# shellcheck shell=bash

load './util/init.sh'

@test "Add works" {
	run basalt global add 'hyperupcall/bash-object@v0.6.3'

	assert_success
	assert [ "$(<"$BASALT_GLOBAL_DATA_DIR/global/dependencies")" = 'https://github.com/hyperupcall/bash-object.git@v0.6.3' ]
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
