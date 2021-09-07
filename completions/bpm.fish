set cmd bpm
set -l listSubcommands add echo init link list package-path prune remove upgrade

# Not only does this prevent appending completion properties to $cmd (we
# want to start from a completely new definition), it also removes incorrect
# completions inferred from '$cmd --help' (by erasing the previous definition)
complete -e $cmd

complete -c $cmd -f -n "not __fish_seen_subcommand_from $listSubcommands" -a "$listSubcommands"

set subcmd add
set -l subcommandOptions --shh
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions"

set subcmd init
set -l subcommandOptions sh bash zsh fish
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions"

set subcmd link
set -l subcommandOptions --no-deps
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions"

set subcmd list
set -l subcommandOptions --outdated
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions"

set subcmd remove
set -l subcommandOptions --all --force
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions (bpm complete upgrade)"

set subcmd upgrade
set -l subcommandOptions
# TODO: only complete if (bpm complete upgrade) was successfull
complete -c $cmd -f -n "__fish_seen_subcommand_from $subcmd" -a "$subcommandOptions (bpm complete upgrade)"
