# shellcheck shell=bash
# shellcheck disable=SC1091

__bats_common_utils_dir="$(dirname "${BASH_SOURCE[0]}")"

# bats-assert
source "$__bats_common_utils_dir/bats-assert/src/assert.bash"
source "$__bats_common_utils_dir/bats-assert/src/refute.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_equal.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_not_equal.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_success.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_failure.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_output.bash"
source "$__bats_common_utils_dir/bats-assert/src/refute_output.bash"
source "$__bats_common_utils_dir/bats-assert/src/assert_line.bash"
source "$__bats_common_utils_dir/bats-assert/src/refute_line.bash"

# bats-file
source "$__bats_common_utils_dir/bats-file/src/file.bash"
source "$__bats_common_utils_dir/bats-file/src/temp.bash"

# bats-support
source "$__bats_common_utils_dir/bats-support/src/output.bash"
source "$__bats_common_utils_dir/bats-support/src/error.bash"
source "$__bats_common_utils_dir/bats-support/src/lang.bash"

unset __bats_common_utils_dir
