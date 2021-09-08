# shellcheck shell=bash

echo_variables_posix() {
	cat <<-EOF
	# basalt variables
	export BASALT_REPO_SOURCE="${BASALT_REPO_SOURCE:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"}"
	export BASALT_CELLAR="${BASALT_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/cellar"}"

	EOF
}

echo_include_posix() {
	cat <<-"EOF"
	# basalt include function
	if [ -f "$BASALT_REPO_SOURCE/pkg/share/include.sh" ]; then
	  . "$BASALT_REPO_SOURCE/pkg/share/include.sh"
	fi

	EOF
}

echo_package_path_posix() {
	cat <<-"EOF"
	# basalt packages PATH
	if [ "${PATH#*$BASALT_CELLAR/bin}" = "$PATH" ]; then
	  export PATH="$BASALT_CELLAR/bin:$PATH"
	fi

	EOF
}

# For each shell, items are printed in order
# - Setting basalt variables
# - Sourcing basalt completion
# - Sourcing basalt 'include' function
# - Setting basalt package PATH
# - Sourcing basalt package completion
do-global-init() {
	if [ "$1" = '-' ]; then
		shift
	fi

	local shell="$1"

	if [ -z "$shell" ]; then
		die "Shell not specified"
	fi

	# Set common basalt variables; add PATH
	case "$shell" in
	fish)
		cat <<-EOF
		# basalt variables
		set -gx BASALT_REPO_SOURCE "${BASALT_REPO_SOURCE:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"}"
		set -gx "${BASALT_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/cellar"}"

		# basalt completion
		source \$BASALT_REPO_SOURCE/completions/basalt.fish

		# basalt include function
		if [ -f "$BASALT_REPO_SOURCE/pkg/share/include.fish" ]
		  source "$BASALT_REPO_SOURCE/pkg/share/include.fish"
		end

		# basalt packages PATH
		if not contains \$BASALT_CELLAR/bin \$PATH
		  set -gx PATH \$BASALT_CELLAR/bin \$PATH
		end

		# basalt packages completions
		# set -gx fish_complete_path \$fish_complete_path
		if [ -d \$BASALT_CELLAR/completions/fish ]
		  for f in \$BASALT_CELLAR/completions/fish/?*.fish
		    source \$f
		  end
		end
		EOF
		;;
	bash)
		echo_variables_posix
		cat <<-EOF
		# basalt completions
		if [ -f "\$BASALT_REPO_SOURCE/completions/basalt.bash" ]; then
		  . "\$BASALT_REPO_SOURCE/completions/basalt.bash"
		fi

		EOF
		echo_include_posix
		cat <<-"EOF"
		source "$BASALT_REPO_SOURCE/pkg/lib/source/basalt-load.sh"

		EOF

		echo_package_path_posix
		cat <<-"EOF"
		# basalt packages completions
		if [ -d "$BASALT_CELLAR/completions/bash" ]; then
		  for f in "$BASALT_CELLAR"/completions/bash/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	zsh)
		echo_variables_posix
		cat <<-EOF
		# basalt completions
		fpath=("\$BASALT_REPO_SOURCE/completions" \$fpath)
		EOF

		echo_include_posix
		cat <<-"EOF"
		source "$BASALT_REPO_SOURCE/pkg/lib/source/basalt-load.sh"

		EOF

		echo_package_path_posix
		cat <<-"EOF"
		# basalt packages completions
		fpath=("$BASALT_CELLAR/completions/zsh/compsys" $fpath)
		if [ -d "$BASALT_CELLAR/completions/zsh/compctl" ]; then
		  for f in "$BASALT_CELLAR"/completions/zsh/compctl/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	sh)
		echo_variables_posix
		echo_include_posix

		echo_package_path_posix
		;;
	*)
		cat <<-EOF
		echo "Error: Shell '$shell' is not a valid shell"
		EOF
		exit 1
	esac
}
