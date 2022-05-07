# shellcheck shell=bash

export BASALT_IS_TESTING='yes'

# Get the current directory of the Basalt git repository
test_util.get_repo_root
REPO_ROOT=$REPLY

# Source Basalt and its dependencies
BASALT_PACKAGE_DIR="$REPO_ROOT/pkg/vendor/bash-core" source "$REPO_ROOT/pkg/vendor/bash-core/.basalt/generated/source_all.sh"
BASALT_PACKAGE_DIR="$REPO_ROOT/pkg/vendor/bash-term" source "$REPO_ROOT/pkg/vendor/bash-term/.basalt/generated/source_all.sh"
for f in "$REPO_ROOT"/pkg/src/{bin,commands,public,util}/?*.sh; do
	source "$f"
done; unset f

# Source testing dependencies
load './vendor/bats-all/load.bash'
load './util/test_util.sh'

# Rather than append '$REPO_ROOT/bin' to the path, create functions with
# the same name. This way, the shell execution context remains the same, which
# allows us to actually mock functions
source "$REPO_ROOT/pkg/src/bin/basalt-package-init.sh"
source "$REPO_ROOT/pkg/src/bin/basalt.sh"
basalt-package-init() { main.basalt-package-init "$@"; }
basalt() { main.basalt "$@"; }

# Testing variables
export XDG_DATA_HOME=
export NO_COLOR= GIT_ASKPASS=
export BASALT_GLOBAL_REPO="$BATS_TEST_TMPDIR/source"
export BASALT_GLOBAL_DATA_DIR="$BATS_TEST_TMPDIR/localshare"

setup() {
	ensure.cd "$BATS_TEST_TMPDIR"
}

teardown() {
	ensure.cd "$BATS_SUITE_TMPDIR"
}
