# Environment

## Global

Global environment variables are both valid globally (after `eval "$(basalt global init bash)"`) and locally (after `eval "$(basalt-package-init)"; basalt.package-init`)

### `BASALT_GLOBAL_REPO`

The location of the source code. By default (when using the `install.sh` script), this will be at `${XDG_DATA_HOME:-$HOME/.local/share}/basalt/source`. If you move this directory to a different location, the value will be reflected accordingly

### `BASALT_GLOBAL_DATA_DIR`

The directory Basalt stores nearly all data. This includes downloaded tarballs, directories extracted from tarballs, and the directories that contain global installations of packages. By default, this has the value of `${XDG_DATA_HOME:-$HOME/.local/share}/basalt`

### `basalt.load`

Sources a particular file of a particular package

For example, the below example sources the `z.sh` file that is present at the root of [rupa/z](https://github.com/rupa/z). Note that you must pass in the website, as well as the repository owner and repository name

```sh
basalt.load --global 'github.com/rupa/z' 'z.sh'
```

If you do not pass a file, it will automatically source a `load.bash` at the root of the repository, if it exists

## Local

Local environment variables are only valid within a Bash package (after `eval "$(basalt-package-init)"; basalt.package-init`)

Note that functions listed here are expected to be called from a Bash execution context

### `BASALT_PACKAGE_DIR`

The full path to the current project. It is calculated by walking up the file tree from `$PWD`, only stopping after detecting a `./basalt.toml`. The directory that was stopped at is the new value of `BASALT_PACKAGE_DIR`

### `basalt.package-load`

Loads all Basalt dependencies

```sh
basalt.package-load
```
