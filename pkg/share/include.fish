
function include
	set package $argv[1]
	set file $argv[2]

	if [ -z $BPM_PREFIX ]
		printf "%s\n" "Error: 'BPM_PREFIX' is empty" >&2
		return 1
	end

	if [ -z $package ] || [ -z $file ]
		printf "%s\n" "Error: Usage: include <package> <file>" >&2
		return 1
	end

	if [ ! -d $BPM_PREFIX/packages/$package ]
		printf "%s\n" "Error: Package '$package' not installed" >&2
		return 1
	end

	if [ ! -f $BPM_PREFIX/packages/$package/$file ]
		printf "%s\n" "Error: File '$BPM_PREFIX/packages/$package/$file' not found" >&2
		return 1
	end

	source "$BPM_PREFIX/packages/$package/$file" >&2
end
