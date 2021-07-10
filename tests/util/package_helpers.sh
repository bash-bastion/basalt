# shellcheck shell=bash
# shellcheck disable=SC2164

create_package() {
	local package="$1"

	mkdir -p "$BPM_ORIGIN_DIR/$package"
	cd "$BPM_ORIGIN_DIR/$package"

	git init .
	touch README
	touch package.sh
	git add .
	git commit -m "Initial commit"

	cd "$BPM_CWD"
}

# @description Creates man pages in the root directory
create.man_root() {
	cd "$BPM_ORIGIN_DIR/$package"

	touch "$1"
	git add .
	git commit -m "Add $1"

	cd "$BPM_CWD"
}


create_exec() {
	local package="$1"
	local exec="$2"

	cd "$BPM_ORIGIN_DIR/$package"

	mkdir -p bin
	touch "bin/$exec"

	git add .
	git commit -m "Add $exec"

	cd "$BPM_CWD"
}
