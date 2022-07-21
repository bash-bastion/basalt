# shellcheck shell=bash

# @internal
core.private.util.init() {
	if [ ${___global_bash_core_has_init__+x} ]; then
		return
	fi

	___global_bash_core_has_init__=
	declare -gA ___global_trap_table___=()
	declare -ga ___global_shopt_stack___=()
}

# @internal
core.private.util.trap_handler_common() {
	local signal_spec="$1"
	local code="$2"

	local trap_handlers=
	IFS=$'\x1C' read -ra trap_handlers <<< "${___global_trap_table___[$signal_spec]}"

	local trap_handler=
	for trap_handler in "${trap_handlers[@]}"; do
		if [ -z "$trap_handler" ]; then
			continue
		fi

		if declare -f "$trap_handler" &>/dev/null; then
			if "$trap_handler" "$code"; then :; else
				return $?
			fi
		else
			core.print_warn "Trap handler function '$trap_handler' that was registered for signal '$signal_spec' no longer exists. Skipping" >&2
		fi
	done; unset -v trap_handler
}

core.private.util.validate_args() {
	local function="$1"
	local arg_count="$2"

	if [ -z "$function" ]; then
		core.panic 'First argument must not be empty'
	fi

	if ((arg_count <= 1)); then
		core.panic 'Must specify at least one signal'
	fi
}

core.private.util.validate_signal() {
	local function="$1"
	local signal_spec="$2"

	if [ -z "$signal_spec" ]; then
		core.panic 'Signal must not be an empty string'
	fi

	local regex='^[0-9]+$'
	if [[ "$signal_spec" =~ $regex ]]; then
		core.panic 'Passing numbers for the signal specs is prohibited'
	fi; unset -v regex
	signal_spec="${signal_spec#SIG}"
	if ! declare -f "$function" &>/dev/null; then
		core.panic "Function '$function' is not defined"
	fi
}

# @description Prints the current error stored
# @internal
core.private.util.err_print() {
	printf '%s\n' 'Error found:'
	printf '%s\n' "  ERRCODE: $ERRCODE" >&2
	printf '%s\n' "  ERR: $ERR" >&2
}

# @description Determine if should print color, given a file descriptor
# @arg 1 File descriptor for terminal check
# @internal
core.private.should_print_color() {
	local fd="$1"
	
	if [ ${NO_COLOR+x} ]; then
		return 1
	fi

	if [[ $FORCE_COLOR == @(1|2|3) ]]; then
		return 0
	elif [[ $FORCE_COLOR == '0' ]]; then
		return 1
	fi

	if [ "$TERM" = 'dumb' ]; then
		return 1
	fi

	if [ -t "$fd" ]; then
		return 0
	fi

	return 1
}