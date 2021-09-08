#!/usr/bin/env sh

clone_dir="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"

if [ -d "$clone_dir" ]; then
	printf '%s\n' "Error: basalt already installed to '$clone_dir'"
	exit 1
fi

git clone 'https://github.com/hyperupcall/basalt' "$clone_dir"

bashrc="$HOME/.bashrc"
if [ -f "$bashrc" ]; then
	cat >> "$bashrc" <<-"EOF"
	# basalt
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
	eval "$(basalt init bash)"
	EOF
fi

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
if [ -f "$zshrc" ]; then
	cat >> "$zshrc" <<-"EOF"
	# basalt
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
	eval "$(basalt init zsh)"
	EOF
fi

fishrc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
if [ -f "$fishrc" ]; then
	cat >> "$fishrc" <<-"EOF"
	# basalt
	set -gx PATH "${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin" $PATH
	source (basalt init fish | psub)
	EOF
fi
