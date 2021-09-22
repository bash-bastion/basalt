# Motivation

A mechanism to facilitate composability within the Bash ecosystem, á la a package manager

The general idea isn't new(popular frameworks such as `oh-my-zsh`, `bash-it`, `bash-oo-framework` exist, while some exploration of package management has been done (`bpkg`, `Basher`)

`oh-my-zsh` and friends are more geared towards reusability in the context of shell initialization

`bash-oo-framework` contains a lot of useful functionality, but as the name implies, it must be used as a framework rather than a library. The project itself recommends directly copying and pasting code from the repository as a usage pattern.

`bpkg` and `Basher` are two projects that fit the criteria, but have some disadvantages. The following lists features of Basalt that are absent from either `bpkg` and/or `Basher` (TODO(not all of this is actually implemented since the rewrite, update later)

- Can install multiple packages at once
- Install local dependencies for a particular project (bpkg and basher)
- Does not use a `package.json` that clobbers with NPM's `package.json` (bpkg)
- Does not automatically invoke `make` commands on your behalf (bpkg)
- Does not automatically source a `package.sh` for package configuration (basher)
- Is able to install more repositories out-of-the-box
- Respects the XDG Base Directory specification (bpkg)
- Is faster (basalt considers exec and subshell creation overhead)
- Has a _much_ improved help output (basher)
- Prints why a command failed, rather than just printing the help menu (basher)
- Better basalt completion scripts
- More flexibly parses command line arguments (basher)
- Install local directories as packages (bpkg)

I forked Basher because it had an excellent test suite and its behavior for installing packages made more sense to me, compared to `bpkg`


There are also other similar projects; neither of which are really fully developed: [bpm-rocks/bpm](https://github.com/bpm-rocks/bpm), [Themis](https://github.com/ByCh4n-Group/themis), [xsh](https://github.com/alexzhangs/xsh), [shpkg](https://github.com/shpkg/shpkg), [jean](https://github.com/ziyaddin/jean), [sparrow](https://github.com/melezhik/sparrow), [tarp](https://code.google.com/archive/p/tarp-package-manager), and [shundle](https://github.com/javier-lopez/shundle).bruh
