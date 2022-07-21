# shellcheck shell=bash

btput() {
	unset -v REPLY

	case $1 in
		# controlling cursor
		sc)
			term.cursor_savepos
			;;
		rc)
			term.cursor_unsavepos
			;;
		home)
			tput home
			;;
		cup)
			term.cursor_to "$1" "$2"
			;;
		cud1)
			tput cud1
			;;
		cuu1)
			tput cuu1
			;;
		civis)
			term.cursor_hide
			;;
		cnorm)
			term.cursor_show
			;;

		# terminal attributes
		longname) ;;
		lines) ;;
		cols) ;;
		colors) ;;

		# text effects
		bold)
			tput bold
			;;
		smul)
			tput smul
			;;
		rmul)
			tput rmul
			;;
		rev)
			tput revi
			;;
		blink)
			btput blink
			;;
		invis)
			itput invis
			;;
		smso)
			tput smso
			;;
		rmso)
			tput rmso
			;;
		sgr0)
			tput sgr0
			;;
		setaf)
			case $2 in
				[0-9]) ;;
				*) ;;
			esac
			;;
		setab)
			case $2 in
				[0-9]) ;;
				*) ;;
			esac
			;;
		dim)
			tput dim
			;;

		# clearing screen
		smcup)
			term.screen_save
			;;
		rmcup)
			term.screen_restore
			;;
		el)
			term.erase_line_end
			;;
		el1)
			term.erase_line_start
			;;
		el2)
			term.erase_line
			;;
		clear)
			tput clear
			;;
		*)
			return
	esac

	# shellcheck disable=SC2059
	printf "$REPLY"
}
