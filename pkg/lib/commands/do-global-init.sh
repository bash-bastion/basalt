# shellcheck shell=bash

echo_variables_posix() {
	# Set main variables (WET)
	local basalt_global_repo="${0%/*}"
	basalt_global_repo="${basalt_global_repo%/*}"; basalt_global_repo="${basalt_global_repo%/*}"

	cat <<-EOF
	# basalt variables
	export BASALT_GLOBAL_REPO="$basalt_global_repo"
	export BASALT_GLOBAL_CELLAR="${BASALT_GLOBAL_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/cellar"}"

	EOF
}

echo_package_path_posix() {
	cat <<-"EOF"
	# basalt path
	if [ "${PATH#*$BASALT_GLOBAL_CELLAR/bin}" = "$PATH" ]; then
	  export PATH="$BASALT_GLOBAL_CELLAR/bin:$PATH"
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
		set -gx BASALT_GLOBAL_REPO "${BASALT_GLOBAL_REPO:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"}"
		set -gx "${BASALT_GLOBAL_CELLAR:-"${XDG_DATA_HOME:-$HOME/.local/share}/basalt/cellar"}"

		# basalt path
		if not contains \$BASALT_GLOBAL_CELLAR/bin \$PATH
		  set -gx PATH \$BASALT_GLOBAL_CELLAR/bin \$PATH
		end

		# basalt completion
		source \$BASALT_GLOBAL_REPO/completions/basalt.fish

		# basalt packages completions
		# set -gx fish_complete_path \$fish_complete_path
		if [ -d \$BASALT_GLOBAL_CELLAR/completions/fish ]
		  for f in \$BASALT_GLOBAL_CELLAR/completions/fish/?*.fish
		    source \$f
		  end
		end
		EOF
		;;
	bash)
		echo_variables_posix
		echo_package_path_posix

		cat <<-"EOF"
		# basalt global functions
		source "$BASALT_GLOBAL_REPO/pkg/lib/source/basalt-load.sh"

		# basalt completions
		if [ -f "$BASALT_GLOBAL_REPO/completions/basalt.bash" ]; then
		  . "$BASALT_GLOBAL_REPO/completions/basalt.bash"
		fi

		# basalt packages completions
		if [ -d "$BASALT_GLOBAL_CELLAR/completions/bash" ]; then
		  for f in "$BASALT_GLOBAL_CELLAR"/completions/bash/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	zsh)
		echo_variables_posix
		echo_package_path_posix

		cat <<-"EOF"
		# basalt global functions
		source "$BASALT_GLOBAL_REPO/pkg/lib/source/basalt-load.sh"

		# basalt completions
		fpath=("$BASALT_GLOBAL_REPO/completions" $fpath)

		# basalt packages completions
		fpath=("$BASALT_GLOBAL_CELLAR/completions/zsh/compsys" $fpath)
		if [ -d "$BASALT_GLOBAL_CELLAR/completions/zsh/compctl" ]; then
		  for f in "$BASALT_GLOBAL_CELLAR"/completions/zsh/compctl/*; do
		    source "$f"
		  done
		  unset f
		fi

		EOF
		;;
	sh)
		echo_variables_posix
		echo_package_path_posix
		;;
	*)
		cat <<-EOF
		echo "Error: Shell '$shell' is not a valid shell"
		EOF
		exit 1
	esac
}
