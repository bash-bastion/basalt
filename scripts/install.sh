#!/usr/bin/env sh

clone_dir="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"

if [ -d "$clone_dir" ]; then
	printf '%s\n' "Error: Basalt already installed to '$clone_dir'" >&2
	exit 1
fi

if git clone 'https://github.com/hyperupcall/basalt' "$clone_dir"; then :; else
	printf '%s\n' "Error: Could not clone Git repository (code $?)" >&2
	exit 1
fi

bashrc="$HOME/.bashrc"
if [ -f "$bashrc" ]; then
	cat >> "$bashrc" <<-"EOF"
	# Basalt
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
	eval "$(basalt global init bash)"
	EOF
fi

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
if [ -f "$zshrc" ]; then
	cat >> "$zshrc" <<-"EOF"
	# Basalt
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
	eval "$(basalt global init zsh)"
	EOF
fi

fishrc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
if [ -f "$fishrc" ]; then
	cat >> "$fishrc" <<-"EOF"
	# Basalt
	set -gx PATH "${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin" $PATH
	source (basalt global init fish | psub)
	EOF
fi
