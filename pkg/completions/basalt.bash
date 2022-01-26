_basalt() {
	local -ra listPreSubcommandOptions=(--help --version)
	local -ra listSubcommands=(add echo init link list package-path prune remove upgrade)

	local -r currentWord="${COMP_WORDS[COMP_CWORD]}"

	# TODO: to support nested subcommands, we should pop everything before the subcommand, and pass
	# it into a function similar to this
	# Loop over 'COMP_WORDS', and extract first subcommand found (nested subcommands is NOT supported)
	# ':1' is added so the first element (command name) in COMP_WORDS is skipped (ex. ls)
	local subcommand=
	local -i subcommandIndex=1
	for word in "${COMP_WORDS[@]:1}"; do
		case $word in
			-*) ;;
			*)
				subcommand="$word"
				break
				;;
		esac

		(( subcommandIndex++ ))
	done

	# If the current word index is less than the subcommand index, it means we are completing something before
	# the subcommand. This can happen if we are completing an option first (before completing a subcommand)
	if (( COMP_CWORD < subcommandIndex )); then
		readarray -t COMPREPLY < <(IFS=' ' compgen -W "${listPreSubcommandOptions[*]}" -- "$currentWord")

	# If the current word index is the same as the subcommand index, it means we are completing the subcommand
	elif (( COMP_CWORD == subcommandIndex )); then
		# Sometimes, Bash thinks the word we are completing is the subcommand, even though it doesn't look like it
		# For example, if after our cursor, is a space, and then the subcommand, it will still think we are completing
		# the subcommand, instead of options that precede the subcommand
		# To remedy this, we get the index of the subcommand from the currently completed line. If our cursor (COMP_POINT)
		# is before it, then the aforementioned caveat applies, and we only try to complete options before the subcommand
		# We add a space before '$subcommand' to ensure it only matches real subcommands (which always have a preceding space)
		subcommand=" $subcommand"
		local rest="${COMP_LINE#*$subcommand}"
		local stringIndexOfSubcommand=$((${#COMP_LINE} - ${#rest} - ${#subcommand}))
		if (( COMP_POINT <= stringIndexOfSubcommand )); then
			readarray -t COMPREPLY < <(IFS=' ' compgen -W "${listPreSubcommandOptions[*]}" -- '')
			return
		fi

		subcommand="${subcommand# }"

		# Now, we are really completing a subcommand. Add 'listPreSubcommandOptions' because this branch is ran even when the
		# $currentWord is empty. Of course, when we enter in a subcommand to be completed, none of the 'listPreSubcommandOptions'
		# will show because they all start with a hyphen
		readarray -t COMPREPLY < <(IFS=' ' compgen -W "${listPreSubcommandOptions[*]} ${listSubcommands[*]}" -- "$currentWord")

	# If the current word index is greater than the subcommand index, it means that we have already completed the subcommand and
	# we are completion options for a particular subcommand
	elif (( COMP_CWORD > subcommandIndex )); then
		local -a subcommandOptions=()
		case $subcommand in
			add)
				subcommandOptions=()
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
			init)
				subcommandOptions=(sh bash zsh fish)
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
			link)
				subcommandOptions=()
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
			list)
				subcommandOptions=(--outdated)
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
			remove)
				subcommandOptions=(--all --force)
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
			upgrade)
				readarray -t subcommandOptions < <(basalt complete upgrade)
				readarray -t COMPREPLY < <(IFS=' ' compgen -W "${subcommandOptions[*]}" -- "$currentWord")
				;;
		esac
	fi

	return 0
}

complete -F _basalt basalt
