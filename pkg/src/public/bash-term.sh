# shellcheck shell=bash

# -------------------------------------------------------- #
#                          Cursor                          #
# -------------------------------------------------------- #

# Move the cursor position to a supplied row and column. Both default to `0` if not supplied
# @arg $1 int row
# @arg $1 int column
term.cursor_to() {
	unset -v REPLY
	local row="${1:-0}"
	local column="${2:-0}"

	# Note that 'f' instead of 'H' is the 'force' variant
	printf -v REPLY '\033[%s;%sH' "$row" "$column"
}

# @description Moves the cursor up. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_up() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sA' "$count"
}

# @description Moves the cursor down. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_down() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sB' "$count"
}

# @description Moves the cursor forward. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_forward() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sC' "$count"
}

# @description Moves the cursor backwards. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_backward() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sD' "$count"
}

# @description Moves the cursor to the next line. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_line_next() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sE' "$count"
}

# @description Moves the cursor to the previous line. Defaults to `1` if not supplied
# @arg $1 int count
term.cursor_line_prev() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sF' "$count"
}

# TODO: name, default?
# @arg $1 int count
term.cursor_tocolumn() {
	unset -v REPLY
	local count="${1:-1}"

	printf -v REPLY '\033[%sG' "$count"
}

# @noargs
term.cursor_savepos() {
	unset -v REPLY

	REPLY=$'\e[s'
}

# @noargs
term.cursor_restorepos() {
	unset -v REPLY

	REPLY=$'\e[u'
}

# @noargs
term.cursor_save() {
	unset -v REPLY

	REPLY=$'\e[7'
}

# @noargs
term.cursor_restore() {
	unset -v REPLY

	REPLY=$'\e[8'
}

# @noargs
term.cursor_hide() {
	unset -v REPLY

	REPLY=$'\e[?25l'
}

# @noargs
term.cursor_show() {
	unset -v REPLY

	REPLY=$'\e[?25h'
}


# -------------------------------------------------------- #
#                          Scroll                          #
# -------------------------------------------------------- #

# @noargs
term.scroll_down() {
	unset -v REPLY

	REPLY=$'\e[D'
}

# @noargs
term.scroll_up() {
	unset -v REPLY

	REPLY=$'\e[M'
}


# -------------------------------------------------------- #
#                            Tab                           #
# -------------------------------------------------------- #

# @noargs
term.tab_set() {
	unset -v REPLY

	REPLY=$'\e[H'
}

# @noargs
term.tab_clear() {
	unset -v REPLY

	REPLY=$'\e[g'
}

# @noargs
term.tab_clearall() {
	unset -v REPLY

	REPLY=$'\e[3g'
}


# -------------------------------------------------------- #
#                           Erase                          #
# -------------------------------------------------------- #

# @noargs
term.erase_line_end() {
	unset -v REPLY

	# Same as '\e[0K'
	REPLY=$'\e[K'
}

# @noargs
term.erase_line_start() {
	unset -v REPLY

	REPLY=$'\e[1K'
}

# @noargs
term.erase_line() {
	unset -v REPLY

	REPLY=$'\e[2K'
}

# @noargs
term.erase_screen_end() {
	unset -v REPLY

	# Same as '\e[0J'
	REPLY=$'\e[J'
}

# @noargs
term.erase_screen_start() {
	unset -v REPLY

	REPLY=$'\e[1J'
}

# @noargs
term.erase_screen() {
	unset -v REPLY

	REPLY=$'\e[2J'
}

# @noargs
term.erase_saved_lines() { # TODO: better name?
	unset -v REPLY

	REPLY=$'\e[3J'
}


# -------------------------------------------------------- #
#                          Screen                          #
# -------------------------------------------------------- #
term.screen_save() {
	unset -v REPLY

	REPLY=$'\e[?1049h'
}

term.screen_restore() {
	unset -v REPLY

	REPLY=$'\e[?1049l'
}


# -------------------------------------------------------- #
#                       Miscellaneous                      #
# -------------------------------------------------------- #

# @description Construct a beep
# @noargs
term.beep() {
	unset -v REPLY

	REPLY=$'\a'
}

# @description Construct hyperlink
# @arg $1 string text
# @arg $2 string url
term.hyperlink() {
	unset -v REPLY
	local text="$1"
	local url="$2"

	printf -v REPLY '\e]8;;%s\e\\%s\e]8;;\e\\' "$url" "$text"
}
