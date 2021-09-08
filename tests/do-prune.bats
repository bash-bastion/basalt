#!/usr/bin/env bats

load 'util/init.sh'

@test "prune works for bin files" {
	local file="$BPM_INSTALL_BIN/file"

	mkdir -p "$BPM_INSTALL_BIN"
	ln -s "/invalid" "$file"

	assert [ -L "$file" ]

	run bpm global prune

	assert_success
	assert [ ! -L "$file" ]
	assert [ ! -e "$file" ]
}

@test "prune works for man files" {
	local file="$BPM_INSTALL_MAN/man1/something.1"

	mkdir -p "$BPM_INSTALL_MAN/man1"
	ln -s "/invalid" "$file"

	assert [ -L "$file"  ]

	run bpm global prune

	assert_success
	assert [ ! -L "$file"  ]
	assert [ ! -e "$file"  ]
}

@test "prune works for completion files" {
	local file1="$BPM_INSTALL_COMPLETIONS/bash/something.bash"
	local file2="$BPM_INSTALL_COMPLETIONS/zsh/compsys/_something.zsh"

	mkdir -p "$BPM_INSTALL_COMPLETIONS"/{bash,zsh/compsys}
	ln -s "/invalid" "$file1"
	ln -s "/invalid" "$file2"

	assert [ -L "$file1"  ]
	assert [ -L "$file2"  ]

	run bpm global prune

	assert_success
	assert [ ! -L "$file1"  ]
	assert [ ! -e "$file1"  ]
	assert [ ! -L "$file2"  ]
	assert [ ! -e "$file2"  ]
}

@test "prune works for relative files" {
	local file="$BPM_INSTALL_BIN/file"

	mkdir -p "$BPM_INSTALL_BIN"
	ln -s "invalid" "$file"

	assert [ -L "$file" ]

	run bpm global prune

	assert_success
	assert [ ! -L "$file" ]
	assert [ ! -e "$file" ]
}
