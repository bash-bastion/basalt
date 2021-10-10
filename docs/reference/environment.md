# Environment

## Global Environment Variables

Global environment variables are both valid globally (after `eval "$(basalt global init bash)"`) and locally (after `eval "$(basalt-package-init)"; basalt.package-init`)

### `BASALT_GLOBAL_REPO`

The location of the source code. By default (when using the `install.sh` script), this will be at `${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source`. If you move this directory to a different location, the value will be reflected accordingly

### `BASALT_GLOBAL_DATA_DIR`

The directory Basalt stores nearly all data. This includes downloaded tarballs, directories extracted from tarballs, and the directories that contain global installations of packages. By default, this has the value of `${XDG_DATA_HOME:-$HOME/.local/share}/basalt`

## Local Environment Variables

Local environment variables are only valid within a Bash package (after `eval "$(basalt-package-init)"; basalt.package-init`)

### `BASALT_PACKAGE_DIR`

The full path to the current project. It is calculated by walking up the file tree from `$PWD`, only stopping after detecting a `./basalt.toml`. The directory that was stopped at is the new value of `BASALT_PACKAGE_DIR`
