# shellcheck shell=bash

echo_bpm_variables_posix() {
	cat <<-EOF
	# bpm variables
	export BPM_REPO_SOURCE="${BPM_REPO_SOURCE:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"}"
	export BPM_CELLAR="${BPM_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm/cellar"}"

	EOF
}

echo_bpm_include_posix() {
	cat <<-"EOF"
	# bpm include function
	if [ -f "$BPM_REPO_SOURCE/pkg/share/include.sh" ]; then
	  . "$BPM_REPO_SOURCE/pkg/share/include.sh"
	fi

	EOF
}

echo_bpm_package_path_posix() {
	cat <<-"EOF"
	# bpm packages PATH
	if [ "${PATH#*$BPM_CELLAR/bin}" = "$PATH" ]; then
	  export PATH="$BPM_CELLAR/bin:$PATH"
	fi

	EOF
}

echo_bpm_source_bpm_load() {
	cat <<-"EOF"
	# bpm-load
	source 'bpm-load'

	EOF
}

# For each shell, items are printed in order
# - Setting bpm variables
# - Sourcing bpm completion
# - Sourcing bpm 'include' function
# - Setting bpm package PATH
# - Sourcing bpm package completion
do-init() {
	if [ "$1" = '-' ]; then
		shift
	fi

	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	# Set common bpm variables; add PATH
	case "$shell" in
	fish)
		cat <<-EOF
		# bpm variables
		set -gx BPM_REPO_SOURCE "${BPM_REPO_SOURCE:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"}"
		set -gx "${BPM_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/bpm/cellar"}"

		# bpm completion
		source \$BPM_REPO_SOURCE/completions/bpm.fish

		# bpm include function
		if [ -f "$BPM_REPO_SOURCE/pkg/share/include.fish" ]
		  source "$BPM_REPO_SOURCE/pkg/share/include.fish"
		end

		# bpm packages PATH
		if not contains \$BPM_CELLAR/bin \$PATH
		  set -gx PATH \$BPM_CELLAR/bin \$PATH
		end

		# bpm packages completions
		# set -gx fish_complete_path \$fish_complete_path
		if [ -d \$BPM_CELLAR/completions/fish ]
		  for f in \$BPM_CELLAR/completions/fish/?*.fish
		    source \$f
		  end
		end
		EOF
		;;
	bash)
		echo_bpm_variables_posix
		cat <<-EOF
		# bpm completions
		if [ -f "\$BPM_REPO_SOURCE/completions/bpm.bash" ]; then
		  . "\$BPM_REPO_SOURCE/completions/bpm.bash"
		fi

		EOF
		echo_bpm_include_posix
		echo_bpm_source_bpm_load

		echo_bpm_package_path_posix
		cat <<-"EOF"
		# bpm packages completions
		if [ -d "$BPM_CELLAR/completions/bash" ]; then
		  for f in "$BPM_CELLAR"/completions/bash/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	zsh)
		echo_bpm_variables_posix
		cat <<-EOF
		# bpm completions
		fpath=("\$BPM_REPO_SOURCE/completions" \$fpath)
		EOF

		echo_bpm_include_posix
		echo_bpm_source_bpm_load

		echo_bpm_package_path_posix
		cat <<-"EOF"
		# bpm packages completions
		fpath=("$BPM_CELLAR/completions/zsh/compsys" $fpath)
		if [ -d "$BPM_CELLAR/completions/zsh/compctl" ]; then
		  for f in "$BPM_CELLAR"/completions/zsh/compctl/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	sh)
		echo_bpm_variables_posix
		echo_bpm_include_posix

		echo_bpm_package_path_posix
		;;
	*)
		cat <<-EOF
		echo "Error: Shell '$shell' is not a valid shell"
		EOF
		exit 1
	esac
}
