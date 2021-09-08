
function include
	set package $argv[1]
	set file $argv[2]

	if [ -z $BASALT_GLOBAL_CELLAR ]
		printf "%s\n" "Error: 'BASALT_GLOBAL_CELLAR' is empty" >&2
		return 1
	end

	if [ -z $package ] || [ -z $file ]
		printf "%s\n" "Error: Usage: include <package> <file>" >&2
		return 1
	end

	if [ ! -d $BASALT_GLOBAL_CELLAR/packages/$package ]
		printf "%s\n" "Error: Package '$package' not installed" >&2
		return 1
	end

	if [ ! -f $BASALT_GLOBAL_CELLAR/packages/$package/$file ]
		printf "%s\n" "Error: File '$BASALT_GLOBAL_CELLAR/packages/$package/$file' not found" >&2
		return 1
	end

	source "$BASALT_GLOBAL_CELLAR/packages/$package/$file" >&2
end
