# shellcheck shell=bash

do-init() {
	util.init_command

	if [ -e basalt.toml ]; then
		die "basalt.toml already exists"
	fi

	# TODO: create directories / files as well / git clone from main template repository
	cat >| basalt.toml <<-"EOF"
	[package]
	name = ""
	version = ""
	authors = []

	dependencies = []
	EOF
}
