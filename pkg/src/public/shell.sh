# shellcheck shell=bash


std.shell_variable_assignment() {
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

std.shell_variable_export() {
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

std.shell_path_prepend() {
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

std.shell_register_completion() {
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

std.shell_register_completions() {
	local dir="$1"

	case $shell in
	fish)

		;;
	zsh)
		printf '%s\n' "fpath=(\"$dir/zsh/compsys\" \$fpath)
   if [ -d \"$dir/zsh/compctl\" ]; then
      for __f in \"$dir/zsh/compctl\"/*; do
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

std.shell_source() {
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
