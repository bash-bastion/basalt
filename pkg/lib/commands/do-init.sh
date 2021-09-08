# shellcheck shell=bash

do-init() {
	util.init_command

	if [ -e bpm.toml ]; then
		die "bpm.toml already exists"
	fi

	# TODO: create directories / files as well / git clone from main template repository
	cat >| bpm.toml <<-"EOF"
	[package]
	name = ""
	version = ""
	authors = []

	dependencies = []
	EOF
}
