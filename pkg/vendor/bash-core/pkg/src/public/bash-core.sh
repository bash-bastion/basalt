# shellcheck shell=bash

# @name bash-core
# @description Core functions for any Bash program

# @description Adds a handler for a particular `trap` signal or event. Noticably,
# unlike the 'builtin' trap, this does not override any other existing handlers
# @arg $1 string Function to execute on an event. Integers are forbiden
# @arg $2 string Event signal
# @example
#   some_handler() { printf '%s\n' 'This was called on USR1! ^w^'; }
#   core.trap_add 'some_handler' 'USR1'
#   kill -USR1 $$
#   core.trap_remove 'some_handler' 'USR1'
core.trap_add() {
	if ! [ ${___global_bash_core_has_init__+x} ]; then
		core.util.init
	fi
	local function="$1"

	# validation
	if [ -z "$function" ]; then
		core.print_error 'First argument must not be empty'
		return 1
	fi

	if (($# <= 1)); then
		core.print_error 'Must specify at least one signal'
		return 1
	fi
	for signal_spec in "${@:2}"; do
		if [ -z "$signal_spec" ]; then
			core.print_error 'Signal must not be an empty string'
			return 1
		fi

		local regex='^[0-9]+$'
		if [[ "$signal_spec" =~ $regex ]]; then
			core.print_error 'Passing numbers for the signal specs is prohibited'
			return 1
		fi; unset regex
		signal_spec=${signal_spec#SIG}
		if ! declare -f "$function" &>/dev/null; then
			core.print_error "Function '$function' is not defined"
			return 1
		fi

		# start
		___global_trap_table___["$signal_spec"]="${___global_trap_table___[$signal_spec]}"$'\x1C'"$function"

		# rho (WET)
		local global_trap_handler_name=
		printf -v global_trap_handler_name '%q' "core.trap_handler_${signal_spec}"

		if ! eval "$global_trap_handler_name() {
		core.util.trap_handler_common '$signal_spec'
	}"; then
			core.print_error 'Could not eval function'
			return 1
		fi
		# shellcheck disable=SC2064
		trap "$global_trap_handler_name" "$signal_spec"
	done
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
		core.util.init
	fi
	local function="$1"

	# validation
	if [ -z "$function" ]; then
		core.print_error 'First argument must not be empty'
		return 1
	fi

	if (($# <= 1)); then
		core.print_error 'Must specify at least one signal'
		return 1
	fi
	for signal_spec in "${@:2}"; do
		if [ -z "$signal_spec" ]; then
			core.print_error 'Signal must not be an empty string'
			return 1
		fi

		local regex='^[0-9]+$'
		if [[ "$signal_spec" =~ $regex ]]; then
			core.print_error 'Passing numbers for the signal specs is prohibited'
			return 1
		fi; unset regex
		signal_spec="${signal_spec#SIG}"
		if ! declare -f "$function" &>/dev/null; then
			core.print_error "Function '$function' is not defined"
			return 1
		fi

		# start
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
		done; unset trap_handler

		___global_trap_table___["$signal_spec"]="$new_trap_handlers"

		# rho (WET)
		local global_trap_handler_name=
		printf -v global_trap_handler_name '%q' "___global_trap_${signal_spec}_handler___"
		unset -f "$global_trap_handler_name"
	done
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
		core.util.init
	fi
	local shopt_action="$1"
	local shopt_name="$2"

	if [ -z "$shopt_action" ]; then
		core.print_error 'First argument cannot be empty'
		return 1
	fi

	if [ -z "$shopt_name" ]; then
		core.print_error 'Second argument cannot be empty'
		return 1
	fi

	local -i previous_shopt_errcode=
	if shopt -q "$shopt_name"; then
		previous_shopt_errcode=$?
	else
		previous_shopt_errcode=$?
	fi

	if [ "$shopt_action" = '-s' ]; then
		if shopt -s "$shopt_name"; then :; else
			# on error, option will not be set
			return $?
		fi
	elif [ "$shopt_action" = '-u' ]; then
		if shopt -u "$shopt_name"; then :; else
			# on error, option will not be set
			return $?
		fi
	else
		core.print_error "Accepted actions are either '-s' or '-u'"
		return 1
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
		core.util.init
	fi

	if (( ${#___global_shopt_stack___[@]} == 0 )); then
		core.print_error 'Unable to pop as nothing is in the shopt stack'
		return 1
	fi

	if (( ${#___global_shopt_stack___[@]} & 1 )); then
		core.print_error 'Shopt stack is malformed'
		return 1
	fi

	# Stack now guaranteed to have at least 2 elements (so the following accessors won't error)
	local shopt_action="${___global_shopt_stack___[-2]}"
	local shopt_name="${___global_shopt_stack___[-1]}"

	if shopt -u "$shopt_name"; then :; else
		local errcode=$?
		core.print_error 'Could not restore previous shopt option'
		return $errcode
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
		core.print_error 'Incorrect function arguments'
		return 1
	fi

	if [ -z "$ERR" ]; then
		core.print_error "Argument for 'ERR' cannot be empty"
		return 1
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

# @description Prints stacktrace
# @noargs
# @example
#  err_handler() {
#    local exit_code=$?
#    core.print_stacktrace
#    exit $exit_code
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

		if ! CDPATH= cd -- "$old_cd"; then
			cd_failed='yes'
		fi
	done; unset -v i

	if [ "$cd_failed" = 'yes' ]; then
		core.print_error "A 'cd' failed, so the stacktrace may include relative paths"
	fi
} >&2

# @description Print an error message to standard error
# @arg $1 string message
core.print_error() {
	local msg="$1"

	printf '%s\n' "Error: ${FUNCNAME[1]}${msg:+": "}$msg" >&2
}

# @description Print a warning message to standard error
# @arg $1 string message
core.print_warn() {
	local msg="$1"

	printf '%s\n' "Warn: ${FUNCNAME[1]}${msg:+": "}$msg" >&2
}

# @description Print an informative message to standard output
# @arg $1 string message
core.print_info() {
	local msg="$1"

	printf '%s\n' "Info: ${FUNCNAME[1]}${msg:+": "}$msg"
}

# @description Determine if color should be printed. Note that this doesn't
# use tput because simple environment variable checking heuristics suffice
core.should_output_color() {
	# https://no-color.org
	if [ ${NO_COLOR+x} ]; then
		return 1
	fi

	# FIXME
	# # 0 => 2 colors
	# # 1 => 16 colors
	# # 2 => 256 colors
	# # 3 => 16,777,216 colors
	# if [[ -v FORCE_COLOR ]]; then
	# 	return 0
	# fi

	if [ "$COLORTERM" = "truecolor" ] || [ "$COLORTERM" = "24bit" ]; then
		return 0
	fi

	if [ "$TERM" = 'dumb' ]; then
		return 1
	fi

	if [ -t 0 ]; then
		return 0
	fi

	return 1
}

# @description Gets information from a particular package. If the key does not exist, then the value
# is an empty string
# @arg $1 string The `$BASALT_PACKAGE_DIR` of the caller
# @set REPLY string The full path to the directory
core.get_package_info() {
	unset REPLY; REPLY=
	local basalt_package_dir="$1"
	local key_name="$2"
	
	local toml_file="$basalt_package_dir/basalt.toml"

	if [ ! -f "$toml_file" ]; then
		core.print_error "File '$toml_file' could not be found"
	fi

	local regex="^[ \t]*${key_name}[ \t]*=[ \t]*['\"](.*)['\"]"
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
	core.util.init
}

# @description (DEPRECATED) Prints stacktrace
# @see core.print_stacktrace
core.stacktrace_print() {
	core.print_warn "The function 'core.stacktrace_print' is deprecated in favor of 'core.print_stacktrace'"
	core.print_stacktrace "$@"
}