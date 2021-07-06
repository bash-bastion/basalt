function __fish_bpm_needs_command
	set cmd (commandline -opc)
	if [ (count $cmd) -eq 1 -a $cmd[1] = 'bpm' ]
		return 0
	end
	return 1
end

function __fish_bpm_using_command
	set cmd (commandline -opc)
	if [ (count $cmd) -gt 1 ]
		if [ $argv[1] = $cmd[2] ]
		return 0
		end
	end
	return 1
end

complete -f -c bpm -n '__fish_bpm_needs_command
' -a '(bpm commands)'

for cmd in (bpm commands)
	complete -f -c bpm -n "__fish_bpm_using_command $cmd" -a "(bpm completions $cmd)"
end
