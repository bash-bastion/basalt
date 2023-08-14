# Installation

## Prerequisites

- `bash >= 4.3`
- GNU coreutils

If you are on macOS, you need to install the latest `Bash` and `coreutils`:

```sh
# Install prerequisite packages
brew install bash coreutils
```

See the full list of supported operating systems in [Support](./docs/support.md).

## Install

### Scripted

```sh
curl -Lo- https://raw.githubusercontent.com/hyperupcall/basalt/main/scripts/install.sh | sh
```

### Manual

##### 1. Clone repository

```sh
git clone https://github.com/hyperupcall/basalt "${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source"
```

By default, this installs basalt to `$HOME/.local/share/basalt/source`.

##### 2. Add initialization script to shell profile

This enables basalt to automatically setup your `PATH`, set completion variables, source completion files, and other things.

For `bash`, `zsh`, `sh`

```sh
export PATH="${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source/bin:$PATH"
eval "$(basalt global init bash)" # replace 'bash' with your shell
```

For `fish`

```fish
if test -n "$XDG_DATA_HOME"
  set -gx PATH $XDG_DATA_HOME/basalt/source/bin $PATH
else
  set -gx PATH $HOME/.local/share/basalt/source/bin $PATH
end

basalt init fish | source
```

And now you're done! Move on to [Getting Started](./docs/tutorials/getting-started.md) to learn the basics.
