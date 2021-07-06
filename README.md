# bpm

Originally a fork of [bpm](https://github.com/bpmpm/bpm), `bpm` is a package manager for Bash repositories.

> Instead of looking for specific install instructions for each package and messing with your path, [bpm] will create a central location for all packages and manage their binaries for you

More specifically, when `bpm` is given a repository to install, it will automatically

- Detect shell-specific completion scripts, and symlink them to a common directory
- Detect executable scripts and symlink them to a common directory
- Detect man pages and symlink them to a common directory

Since the completions and executables are in a common directory, it's much easier to make PATH / completion modifications

## Alternatives Comparison

### Compared to `bpkg`, `bpm`

- Can install multiple packages at once
- Does not use a `package.json` that clobbers with NPM's
- Does not automatically invoke `make install` commands on your behalf
- Probably is able to install more repositories (not verified)
- Respects XDG
- Is likely faster

### Compared to `bpm`, `bpm`

- Can install multiple packages at once
- Has an improved help output
- Prints why a command failed (rather than just showing the help menu)
- Has more modern code
- Better bpm completion scripts
- Is faster (less exec'ing Bash processes and subshell creations)
- Does not source `package.sh` which allows for arbitrary command execution
- More flexible parsing of command line arguments

Even though it is called bpm, it also works with zsh and fish.

## Installation

STATUS: IN DEVELOPMENT

`bpm` requires `bash >= 4`, and the `realpath` utility from `coreutils`. On
osx you can install both with brew:

```sh
brew install bash coreutils
```

1. Clone `bpm``

```sh
git clone https://github.com/bpmpm/bpm "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"
```

2. Initialize `bpm` in your shell initialization

For `bash`, `zsh`, `sh`

```sh
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin:$PATH"
eval "$(bpm init bash)" # replace 'bash' with your shell
```

For `fish`

```fish
set -gx PATH "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin" $PATH
status --is-interactive; and . (bpm init fish | psub)
```

## Updating

Go to the directory where you cloned bpm and pull the latest changes

```sh
cd "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"
git pull
```

## Usage

### Installing packages from Github

```sh
bpm install sstephenson/bats
```

This will install [Bats](https://github.com/sstephenson/bats) and add its `./bin` to the `PATH`.

### Installing packages from other sites

```sh
bpm install bitbucket.org/user/repo_name
```

This will install `repo_name` from https://bitbucket.org/user/repo_name

### Installing a local package

If you develop a package locally and want to try it through Basher,
use the `link` subcommand

```sh
bpm link ./directory my_namespace/my_package
```

The `link` command will install the dependencies of the local package.
You can prevent that with the `--no-deps` option

### Sourcing files from a package into current shell

`bpm` provides an `include` function that allows sourcing files into the
current shell. After installing a package, you can run:

```sh
include username/repo lib/file.sh
```

## Contributing

```sh
git clone https://github.com/eankeen/bpm
cd bpm
git submodule update --init
make test
```
