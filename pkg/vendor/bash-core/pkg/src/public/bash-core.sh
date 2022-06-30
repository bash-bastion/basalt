# shellcheck shell=bash

# @name bash-core
# @description Core functions for any Bash program

# @description Adds a handler for a particular `trap` signal or event. Noticably,
# unlike the 'builtin' trap, this does not override any other existing handlers. The first argument
# to the handler is the exit code of the last command that ran before the particular 'trap'
# @arg $1 string Function to execute on an event. Integers are forbiden
# @arg $2 string Event signal
# @example
#   some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
#   core.trap_add 'some_handler' 'USR1'
#   kill -USR1 $$
#   core.trap_remove 'some_handler' 'USR1'
core.trap_add() {
	if ! [ ${___global_bash_core_has_init__+x} ]; then
		core.private.util.init
	fi
	local function="$1"

	core.private.util.validate_args "$function" $#
	for signal_spec in "${@:2}"; do
		core.private.util.validate_signal "$function" "$signal_spec"

		___global_trap_table___["$signal_spec"]="${___global_trap_table___[$signal_spec]}"$'\x1C'"$function"

		# rho (WET)
		local global_trap_handler_name=
		printf -v global_trap_handler_name '%q' "core.private.trap_handler_${signal_spec}"

		if ! eval "$global_trap_handler_name() {
		local ___exit_code_original=\$?
		if core.private.util.trap_handler_common '$signal_spec' \"\$___exit_code_original\"; then
			return \$___exit_code_original
		else
			local ___exit_code_user=\$?
			core.print_error_fn \"User-provided trap handler spectacularly failed with exit code \$___exit_code_user\"
			return \$___exit_code_user
		fi
	}"; then
			core.panic 'Failed to eval function'
		fi
		# shellcheck disable=SC2064
		trap "$global_trap_handler_name" "$signal_spec"
	done; unset -v signal_spec
}

# @description Removes a handler for a particular `trap` signal or event. Currently,
# if the function doest not exist, it prints an error
# @arg $1 string Function to remove
# @arg $2 string Signal that the function executed on
# @example
#   some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
#   core.trap_add 'some_handler' 'USR1'
#   kill -USR1 $$
#   core.trap_remove 'some_handler' 'USR1'
core.trap_remove() {
	if ! [ ${___global_bash_core_has_init__+x} ]; then
		core.private.util.init
	fi
	local function="$1"

	core.private.util.validate_args "$function" $#
	for signal_spec in "${@:2}"; do
		core.private.util.validate_signal "$function" "$signal_spec"

		local -a trap_handlers=()
		local new_trap_handlers=
		IFS=$'\x1C' read -ra trap_handlers <<< "${___global_trap_table___[$signal_spec]}"
		for trap_handler in "${trap_handlers[@]}"; do
			if [ -z "$trap_handler" ] || [ "$trap_handler" = $'\x1C' ]; then
				continue
			fi

			if [ "$trap_handler" = "$function" ]; then
				continue
			fi

			new_trap_handlers+=$'\x1C'"$trap_handler"
		done; unset -v trap_handler

		___global_trap_table___["$signal_spec"]="$new_trap_handlers"

		# If there are no more user-provided trap-handlers (for the particular signal spec in the global trap table),
		# then remove our handler from 'trap'
		if [ -z "$new_trap_handlers" ]; then
			# rho (WET)
			local global_trap_handler_name=
			printf -v global_trap_handler_name '%q' "core.private.trap_handler_${signal_spec}"
			trap -- "$signal_spec"
			unset -f "$global_trap_handler_name"
		fi
	done; unset -v signal_spec
}

# @description Modifies current shell options and pushes information to stack, so
# it can later be easily undone. Note that it does not check to see if your Bash
# version supports the option
# @arg $1 string Name of shopt action. Can either be `-u` or `-s`
# @arg $2 string Name of shopt name
# @example
#   core.shopt_push -s extglob
#   [[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
#   core.shopt_pop
core.shopt_push() {
	if ! [ ${___global_bash_core_has_init__+x} ]; then
		core.private.util.init
	fi
	local shopt_action="$1"
	local shopt_name="$2"

	if [ -z "$shopt_action" ]; then
		core.panic 'First argument cannot be empty'
	fi

	if [ -z "$shopt_name" ]; then
		core.panic 'Second argument cannot be empty'
	fi

	local -i previous_shopt_errcode=
	if shopt -q "$shopt_name"; then
		previous_shopt_errcode=$?
	else
		previous_shopt_errcode=$?
	fi

	if [ "$shopt_action" = '-s' ]; then
		if shopt -s "$shopt_name"; then :; else
			core.panic "Could not set shopt option" $?
		fi
	elif [ "$shopt_action" = '-u' ]; then
		if shopt -u "$shopt_name"; then :; else
			core.panic "Could not unset shopt option" $?
		fi
	else
		core.panic "Accepted actions are either '-s' or '-u'"
	fi

	if (( previous_shopt_errcode == 0)); then
		___global_shopt_stack___+=(-s "$shopt_name")
	else
		___global_shopt_stack___+=(-u "$shopt_name")
	fi
}

# @description Modifies current shell options based on most recent item added to stack.
# @noargs
# @example
#   core.shopt_push -s extglob
#   [[ 'variable' == @(foxtrot|golf|echo|variable) ]] && printf '%s\n' 'Woof!'
#   core.shopt_pop
core.shopt_pop() {
	if ! [ ${___global_bash_core_has_init__+x} ]; then
		core.private.util.init
	fi

	if (( ${#___global_shopt_stack___[@]} == 0 )); then
		core.panic 'Unable to pop as nothing is in the shopt stack'
	fi

	if (( ${#___global_shopt_stack___[@]} & 1 )); then
		core.panic 'Shopt stack is malformed'
	fi

	# Stack now guaranteed to have at least 2 elements (so the following accessors won't error)
	local shopt_action="${___global_shopt_stack___[-2]}"
	local shopt_name="${___global_shopt_stack___[-1]}"

	if shopt -u "$shopt_name"; then :; else
		core.panic 'Could not restore previous shopt option' $?
	fi

	___global_shopt_stack___=("${___global_shopt_stack___[@]::${#___global_shopt_stack___[@]}-2}")
}

# @description Sets an error.
# @arg $1 Error code
# @arg $2 Error message
# @set number ERRCODE Error code
# @set string ERR Error message
core.err_set() {
	if (($# == 1)); then
		ERRCODE=1
		ERR=$1
	elif (($# == 2)); then
		ERRCODE=$1
		ERR=$2
	else
		core.panic 'Incorrect function arguments'
	fi

	if [ -z "$ERR" ]; then
		core.panic "Argument for 'ERR' cannot be empty"
	fi
}

# @description Clears any of the global error state (sets to empty string).
# This means any `core.err_exists` calls after this _will_ `return 1`
# @noargs
# @set number ERRCODE Error code
# @set string ERR Error message
core.err_clear() {
	ERRCODE=
	ERR=
}

# @description Checks if an error exists. If `ERR` is not empty, then an error
# _does_ exist
# @noargs
core.err_exists() {
	if [ -z "$ERR" ]; then
		return 1
	else
		return 0
	fi
}

# @description Use when a serious fault occurs. It will print the current ERR (if it exists)
core.panic() {
	local code='1'
	if [[ $1 =~ [0-9]+ ]]; then
		code=$1
	elif [ -n "$1" ]; then
		if [ -n "$2" ]; then
			code=$2
		fi
		if core.private.should_print_color 2; then
			printf "\033[1;31m\033[4m%s:\033[0m %s\n" 'Panic' "$1" >&2
		else
			printf "%s: %s\n" 'Panic' "$1" >&2
		fi
	fi

	if core.err_exists; then
		core.private.util.err_print
	fi
	core.print_stacktrace
	exit "$code"
}

# @description Prints stacktrace
# @noargs
# @example
#  err_handler() {
#    local exit_code=$1 # Note that this isn't `$?`
#    core.print_stacktrace
#    
#    # Note that we're not doing `exit $exit_code` because
#    # that is handled automatically
#  }
#  core.trap_add 'err_handler' ERR
core.print_stacktrace() {
	printf '%s\n' 'Stacktrace:'

	local old_cd="$PWD" cd_failed='no'
	local i=
	for ((i=0; i<${#FUNCNAME[@]}-1; ++i)); do
		local file="${BASH_SOURCE[$i]}"

		# If the 'cd' has previous failed, then do not attempt to 'cd' as the current
		# directory is not in '$old_cd' (so the 'cd' will almost certainly fail)
		if [ "$cd_failed" = 'no' ]; then
			# shellcheck disable=SC1007
			if CDPATH= cd -- "${file%/*}"; then
				file="$PWD/${file##*/}"
			else
				cd_failed='yes'
			fi
		fi

		printf '%s\n' "  in ${FUNCNAME[$i]} ($file:${BASH_LINENO[$i-1]})"

		# shellcheck disable=SC1007
		if ! CDPATH= cd -- "$old_cd"; then
			cd_failed='yes'
		fi
	done; unset -v i

	if [ "$cd_failed" = 'yes' ]; then
		# Do NOT 'core.panic'
		core.print_error "A 'cd' failed, so the stacktrace may include relative paths"
	fi
} >&2

# @description Print a fatal error message including the function name of the callee
# to standard error
# @arg $1 string message
core.print_fatal_fn() {
	local msg="$1"

	core.print_fatal "${FUNCNAME[1]}()${msg:+": "}$msg"
}

# @description Print an error message including the function name of the callee
# to standard error
# @arg $1 string message
core.print_error_fn() {
	local msg="$1"

	core.print_error "${FUNCNAME[1]}()${msg:+": "}$msg"
}

# @description Print a warning message including the function name of the callee
# to standard error
# @arg $1 string message
core.print_warn_fn() {
	local msg="$1"

	core.print_warn "${FUNCNAME[1]}()${msg:+": "}$msg"
}

# @description Print an informative message including the function name of the callee
# to standard output
# @arg $1 string message
core.print_info_fn() {
	local msg="$1"

	core.print_info "${FUNCNAME[1]}()${msg:+": "}$msg"
}
# @description Print a debug message including the function name of the callee
# to standard output
# @arg $1 string message
core.print_debug_fn() {
	local msg="$1"

	core.print_debug "${FUNCNAME[1]}()${msg:+": "}$msg"
}

# @description Print a error message to standard error and die
# @arg $1 string message
core.print_die() {
	core.print_fatal "$1"
	exit 1
}

# @description Print a fatal error message to standard error
# @arg $1 string message
core.print_fatal() {
	local msg="$1"

	if core.private.should_print_color 2; then
		printf "\033[1;35m%s:\033[0m %s\n" 'Fatal' "$msg" >&2
	else
		printf "%s: %s\n" 'Fatal' "$msg" >&2
	fi
}

# @description Print an error message to standard error
# @arg $1 string message
core.print_error() {
	local msg="$1"

	if core.private.should_print_color 2; then
		printf "\033[1;31m%s:\033[0m %s\n" 'Error' "$msg" >&2
	else
		printf "%s: %s\n" 'Error' "$msg" >&2
	fi
}

# @description Print a warning message to standard error
# @arg $1 string message
core.print_warn() {
	local msg="$1"

	if core.private.should_print_color 2; then
		printf "\033[1;33m%s:\033[0m %s\n" 'Warn' "$msg" >&2
	else
		printf "%s: %s\n" 'Warn' "$msg" >&2
	fi
}

# @description Print an informative message to standard output
# @arg $1 string message
core.print_info() {
	local msg="$1"

	if core.private.should_print_color 1; then
		printf "\033[1;32m%s:\033[0m %s\n" 'Info' "$msg" >&2
	else
		printf "%s: %s\n" 'Info' "$msg" >&2
	fi
}

# @description Print a debug message to standard output if the environment variable "DEBUG" is present
# @arg $1 string message
core.print_debug() {
	if [[ -v DEBUG ]]; then
		printf "%s: %s\n" 'Debug' "$msg"
	fi
}

# @description (DEPRECATED). Determine if color should be printed. Note that this doesn't
# use tput because simple environment variable checking heuristics suffice. Deprecated because this code
# has been moved to bash-std
core.should_output_color() {
	local fd="$1"

	if [[ ${NO_COLOR+x} || "$TERM" = 'dumb' ]]; then
		return 1
	fi

	if [ -t "$fd" ]; then
		return 0
	fi

	return 1
}

# @description (DEPRECATED) Gets information from a particular package. If the key does not exist, then the value
# is an empty string. Deprecated as this code has been moved to bash-std
# @arg $1 string The `$BASALT_PACKAGE_DIR` of the caller
# @set directory string The full path to the directory
core.get_package_info() {
	unset REPLY; REPLY=
	local basalt_package_dir="$1"
	local key_name="$2"
	
	local toml_file="$basalt_package_dir/basalt.toml"

	if [ ! -f "$toml_file" ]; then
		core.panic "File '$toml_file' could not be found"
	fi

	local regex=$'^[ \t]*'"${key_name}"$'[ \t]*=[ \t]*[\'"](.*)[\'"]'
	while IFS= read -r line || [ -n "$line" ]; do
		if [[ $line =~ $regex ]]; then
			REPLY=${BASH_REMATCH[1]}
			break
		fi
	done < "$toml_file"; unset -v line
}

# @description (DEPRECATED) Initiates global variables used by other functions. Deprecated as
# this function is called automatically by functions that use global variables
# @noargs
core.init() {
	core.private.util.init
}

# @description (DEPRECATED) Prints stacktrace
# @see core.print_stacktrace
core.stacktrace_print() {
	core.print_warn "The function 'core.stacktrace_print' is deprecated in favor of 'core.print_stacktrace'"
	core.print_stacktrace "$@"
}