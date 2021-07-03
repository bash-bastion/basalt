#!/usr/bin/env bash
#
# Summary: Display help for a command
#
# Usage: basher help [--usage] COMMAND
#
# Parses and displays help contents from a command's source file.
#
# A command is considered documented if it starts with a comment block
# that has a `Summary:' or `Usage:' section. Usage instructions can
# span multiple lines as long as subsequent lines are indented.
# The remainder of the comment block is displayed as extended
# documentation.

command_path() {
  local command="$1"
  if ! command -v basher-"$command"; then
    :
  fi
}

extract_initial_comment_block() {
  sed -ne "
    /^#/ !{
      q
    }

    s/^#$/# /

    /^# / {
      s/^# //
      p
    }
  "
}

collect_documentation() {
  awk '
    /^Summary:/ {
      summary = substr($0, 10)
      next
    }

    /^Usage:/ {
      reading_usage = 1
      usage = usage "\n" $0
      next
    }

    /^( *$|       )/ && reading_usage {
      usage = usage "\n" $0
      next
    }

    {
      reading_usage = 0
      help = help "\n" $0
    }

    function escape(str) {
      gsub(/[`\\$"]/, "\\\\&", str)
      return str
    }

    function trim(str) {
      sub(/^\n*/, "", str)
      sub(/\n*$/, "", str)
      return str
    }

    END {
      if (usage || summary) {
        print "summary=\"" escape(summary) "\""
        print "usage=\"" escape(trim(usage)) "\""
        print "help=\"" escape(trim(help)) "\""
      }
    }
  '
}

documentation_for() {
  local filename

  # test for file first, since we don't want command -v to return a function
  if [ -f "$bin_path/subcmds/$command.sh" ]; then
    filename="$bin_path/subcmds/$command.sh"
  elif command -v basher-"$command" &>/dev/null; then
    filename="$(command -v basher-"$command")"
  fi


  if [ -n "$filename" ]; then
    if [ "$(type -t "$filename")" = "function" ]; then
      # TODO
      # doesn't work because bash does not include comments in functions
      extract_initial_comment_block < <(
        type "$filename" | sed '$ d' | sed '1d' | sed '1d' | sed '1d' | sed 's/^    //' \
      ) | collect_documentation
    else
      extract_initial_comment_block < "$filename" | collect_documentation
    fi
  fi
}

print_summary() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"

  if [ -n "$summary" ]; then
    printf "   %-12s   %s\n" "$command" "$summary"
  fi
}

print_help() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"
  if [ -z "$help" ]; then
    help="$summary"
  fi

  if [ -n "$usage" -o -n "$summary" ]; then
    if [ -n "$usage" ]; then
      echo "$usage"
    else
      echo "Usage: basher $command"
    fi
    if [ -n "$help" ]; then
      echo
      echo "$help"
      echo
    fi
  else
    echo "Sorry, this command isn't documented yet." >&2
    return 1
  fi
}

print_usage() {
  local command="$1"
  local summary usage help
  eval "$(documentation_for "$command")"
  if [ -n "$usage" ]; then
    echo "$usage"
  fi
}

basher-help() {
  util.test_mock

  unset usage
  if [ "$1" = "--usage" ]; then
    usage="1"
    shift
  fi

  if [[ -z "$1" || "$1" == "basher" ]]; then
    echo "Usage: basher <command> [<args>]"
    if [ -n "$usage" ]; then
      exit
    fi

    echo
    echo "Some useful basher commands are:"
    for command in $(util.get_basher_subcommands) new-command; do
      print_summary "$command"
    done
    echo
    echo "See 'basher help <command>' for information on a specific command."
  else
    command="$1"

    if [ -n "$(command_path "$command")" ]; then
      if [ -n "$usage" ]; then
        print_usage "$command"
      else
        print_help "$command"
      fi
    elif [ -f "$bin_path/subcmds/$command.sh" ]; then
      if [ -n "$usage" ]; then
        print_usage "$command"
      else
        print_help "$command"
      fi
    else
      echo "basher: help: no such command '$command'" >&2
      exit 1
    fi
  fi
}
