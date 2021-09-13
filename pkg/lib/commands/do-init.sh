# shellcheck shell=bash

do-init() {
	if [ -e basalt.toml ]; then
		print_simple.die "File 'basalt.toml' already exists"
	fi

	# TODO: create directories / files as well / git clone from main template repository
	cat >| basalt.toml <<-"EOF"
	[package]
	name = ""
	version = ""
	authors = []

	dependencies = []
	EOF

	print_simple.info "Created basalt.toml"
}
