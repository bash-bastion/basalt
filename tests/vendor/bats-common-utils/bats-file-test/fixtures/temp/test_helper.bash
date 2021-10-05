export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/../../.."
export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/..}"

# Load dependencies and library.
load "${TEST_MAIN_DIR}/load.bash"
