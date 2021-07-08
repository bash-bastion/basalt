# Getting Started

## Installation

STATUS: IN DEVELOPMENT

`bpm` requires `bash >= 4.3`, and the `realpath` utility from `coreutils`. On
osx you can install both with brew:

```sh
brew install bash coreutils
```

1. Clone `bpm`

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

```sh
$ bash2048.sh
Bash 2048 v1.1 (https://github.com/mydzor/bash2048) pieces=6 target=2048 score=60

/------+------+------+------\
|      |      |      |      |
|------+------+------+------|
|    4 |      |      |      |
|------+------+------+------|
|    2 |    2 |      |      |
|------+------+------+------|
|   16 |    8 |      |    2 |
\------+------+------+------/
```
