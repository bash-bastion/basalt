# shellcheck shell=bash
# shellcheck disable=SC2016

do-global-init() {
	local shell="$1"

	if [ -z "$shell" ]; then
		bprint.die "Shell not specified"
	fi

	if [[ $shell != @(fish|zsh|ksh|bash|sh) ]]; then
		bprint.die "Shell not supported"
	fi

	# Get actual location of source code; only symlink when required
	local basalt_global_repo=
	if [ -L "$0" ]; then
		if ! basalt_global_repo=$(readlink -f "$0"); then
			printf '%s\n' "printf '%s\n' \"Error: basalt-package-init: Invocation of readlink failed\""
			printf '%s\n' 'exit 1'
		fi
		basalt_global_repo=${basalt_global_repo%/*}
	else
		basalt_global_repo=${0%/*}
	fi
	basalt_global_repo=${basalt_global_repo%/*}; basalt_global_repo=${basalt_global_repo%/*}

	# Variables
	printf '%s\n' '# Set variables'
	shell.variable_assignment 'BASALT_GLOBAL_REPO' "$basalt_global_repo"
	shell.variable_assignment 'BASALT_GLOBAL_DATA_DIR' "${BASALT_GLOBAL_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/basalt}"
	shell.variable_export 'BASALT_GLOBAL_REPO'
	shell.variable_export 'BASALT_GLOBAL_DATA_DIR'
	printf '\n'

	# Basalt
	printf '%s\n' '# For Basalt'
	shell.source '$BASALT_GLOBAL_REPO/pkg/src/public' 'basalt-global'
	shell.register_completion '$BASALT_GLOBAL_REPO/completions' 'basalt'
	printf '\n'

	# Basalt packages
	printf '%s\n' "# For Basalt packages"
	shell.path_prepend '$BASALT_GLOBAL_DATA_DIR/global/bin'
	shell.register_completions '$BASALT_GLOBAL_DATA_DIR/global/completion'
	printf '\n'
}

shell.variable_assignment() {
	local variable="$1"
	local value="$2"

	case $shell in
	fish)
		printf '%s\n' "set $variable \"$value\""
		;;
	*)
		printf '%s\n' "$variable=\"$value\""
		;;
	esac
}

shell.variable_export() {
	local variable="$1"

	case $shell in
	fish)
		printf '%s\n' "set -gx $variable"
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' "export $variable"
		;;
	esac
}

shell.path_prepend() {
	local value="$1"

	case $shell in
	fish)
		printf '%s\n' "if not contains $value \$PATH
   set PATH $value
end"
		;;
	zsh|ksh|bash|sh)
		printf '%s\n' "case :\$PATH: in
   *:\"$value\":*) :;;
   *) PATH=$value\${PATH:+:\$PATH}
esac"
		;;
	esac
}

shell.register_completion() {
	local dir="$1"
	local name="$2"

	case $shell in
	fish)
		printf '%s\n' "source $dir/$name.fish"
		;;
	zsh)
		printf '%s\n' "fpath=(\"$dir\" \$fpath)"
		;;
	ksh)
		;;
	bash)
		printf '%s\n' "source \"$dir/$name.bash\""
		;;
	sh)
		;;
	esac
}

shell.register_completions() {
	local dir="$1"

	case $shell in
	fish)

		;;
	zsh)
		printf '%s\n' "fpath=(\"$dir/zsh/compsys\" \$fpath)
   if [ -d \"$dir/zsh/compctl\" ]; then
      for __f in \"$dir/zsh/compctl/*; do
         source \"\$__f\"
      done; unset -v __f
   fi"
		;;
	ksh)
		;;
	bash)
		printf '%s\n' "if [ -d \"$dir/bash/\" ]; then
   for __f in \"$dir/bash\"/*; do
      if [ -f \"\$__f\" ]; then
         source \"\$__f\"
      fi
   done; unset -v __f
fi"
		;;
	sh)
		;;
	esac
}

shell.source() {
	local dir="$1"
	local file="$2"

	case $shell in
	fish)
		printf '%s\n' "source \"$dir/$file\".fish"
		;;
	zsh|ksh|bash)
		printf '%s\n' "source \"$dir/$file.sh\""
		;;
	sh)
		printf '%s\n' ". \"$dir/$file.sh\""
		;;
	esac
}
