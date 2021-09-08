# Installation

Note: `basalt` is currently BETA quality

## Prerequisites

- `bash >= 4.3`
- GNU coreutils

If you are on macOS, you need to install the latest `bash` and `coreutils`:

```sh
# Install prerequisite packages
brew install bash coreutils
```

See the full list of supported operating systems in [Support](./support.md)

## Install

### Scripted

```sh
curl -Lo- https://raw.githubusercontent.com/hyperupcall/basalt/main/scripts/install.sh | bash
```

### Manual

##### 1. Clone `basalt`

```sh
git clone https://github.com/hyperupcall/basalt "${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"
```

By default, this installs basalt to `$HOME/.local/share/basalt/source`. Note: do _NOT_ try to install the repository to a different location (like `~/.basalt`), or the program won't work

##### 2. Add initialization script to shell profile

This enables basalt to automatically setup your `PATH`, set completion variables, source completion files, and other things


For `bash`, `zsh`, `sh`

```sh
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/pkg/bin:$PATH"
eval "$(basalt init bash)" # replace 'bash' with your shell
```

For `fish`

```fish
if test -n "$XDG_DATA_HOME"
  set -gx PATH $XDG_DATA_HOME/basalt/source/pkg/bin $PATH
else
  set -gx PATH $HOME/.local/share/basalt/source/pkg/bin $PATH
end

basalt init fish | source
```

And now you're done! Move on to [Getting Started](./getting-started.md) to learn the basics
