# bpm

Originally a fork of [basher](https://github.com/basherpm/basher), `bpm` is a package manager for Bash repositories.

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

### Compared to `basher`, `bpm`

- Can install multiple packages at once
- Has an improved help output
- Prints why a command failed (rather than just showing the help menu)
- Has more modern code
- Better bpm completion scripts
- Is faster (less exec'ing Bash processes and subshell creations)
- Does not source `package.sh` which allows for arbitrary command execution
- More flexible parsing of command line arguments

Even though it is called basher, it also works with zsh and fish.

## Installation

STATUS: IN DEVELOPMENT

Neobasher requires `bash >= 4`, and the `realpath` utility from `coreutils`. On
osx you can install both with brew:

```sh
brew install bash coreutils
```

1. Clone Neobasher

```sh
git clone https://github.com/basherpm/basher "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source"
```

2. Initialize Neobasher in your shell initialization

For `bash`, `zsh`, `sh`

```sh
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin:$PATH"
eval "$(basher init bash)" # replace 'bash' with your shell
```

For `fish`

```fish
set -gx PATH "${XDG_DATA_HOME:-$HOME/.local/share}/bpm/source/pkg/bin" $PATH
status --is-interactive; and . (basher init fish | psub)
```

## Updating

Go to the directory where you cloned Neoasher and pull the latest changes

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

Neobasher provides an `include` function that allows sourcing files into the
current shell. After installing a package, you can run:

```sh
include username/repo lib/file.sh
```

### Configuration options

To change the behavior of basher, you can set the following variables either
globally or before each command:

- `BPM_ROOT` - The location of the root Neobasher folder. Defaults to `"${XDG_DATA_HOME:-$HOME/.local/share}/bpm"`
- `BPM_FULL_CLONE=true` - Clones the full repo history instead of only the last commit (useful for package development)
- `BPM_PREFIX` - set the installation and package checkout prefix (default is `$BPM_ROOT/cellar`).  Setting this to `/usr/local`, for example, will install binaries to `/usr/local/bin`, manpages to `/usr/local/man`, completions to `/usr/local/completions`, and clone packages to `/usr/local/packages`.  This allows you to manage "global packages", distinct from individual user packages.

## Packages

Packages are simply repos (username/repo). You may also specify a site
(site/username/repo).

Any files inside a bin directory are added to the path. If there is no bin
directory, any executable files in the package root are added to the path.

Any manpages (files ended in `\.[0-9]`) inside a `man` directory are added
to the manpath.

Optionally, a repo might contain a `package.sh` file which specifies binaries,
dependencies and completions in the following format:

```sh
BINS="folder/file1:folder/file2.sh"
DEPS="user1/repo1:user2/repo2"
BASH_COMPLETIONS="completions/package"
ZSH_COMPLETIONS="completions/_package"
```

BINS specified in this fashion have higher precedence then the inference rules above

## Contributing

```sh
git clone https://github.com/eankeen/bpm
cd bpm
git submodule update --init
make test
```
