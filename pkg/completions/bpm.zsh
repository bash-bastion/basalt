if [[ ! -o interactive ]]; then
		return
fi

compctl -K _bpm bpm

_bpm() {
	local words completions
	read -cA words

	if [ "${#words}" -eq 2 ]; then
		completions="$(basher commands)"
	else
		completions="$(basher completions ${words[2,-2]})"
	fi

	reply=("${(ps:\n:)completions}")
}
