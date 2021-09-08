#!/usr/bin/env sh

clone_dir="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"

if [ -d "$clone_dir" ]; then
	printf '%s\n' "Error: bpm already installed to '$clone_dir'"
	exit 1
fi

git clone 'https://github.com/hyperupcall/basalt' "$clone_dir"

bashrc="$HOME/.bashrc"
if [ -f "$bashrc" ]; then
	cat >> "$bashrc" <<-"EOF"
	# bpm
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin:$PATH"
	eval "$(bpm init bash)"
	EOF
fi

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
if [ -f "$zshrc" ]; then
	cat >> "$zshrc" <<-"EOF"
	# bpm
	export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin:$PATH"
	eval "$(bpm init zsh)"
	EOF
fi

fishrc="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
if [ -f "$fishrc" ]; then
	cat >> "$fishrc" <<-"EOF"
	# bpm
	set -gx PATH "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin" $PATH
	source (bpm init fish | psub)
	EOF
fi
