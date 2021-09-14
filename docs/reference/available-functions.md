# Available

Basalt provides various functions in certain contexts. This page details them

## Global Context

Global environment variables are both valid globally (after `eval "$(basalt global init bash)"`) and locally (after `eval "$(basalt-package-init)"; basalt.package-init`)

### basalt.load

Sources a particular file of a particular package

For example, the below example sources the `z.sh` file that is present at the root of [rupa/z](https://github.com/rupa/z). Note that you must pass in the website, as well as the repository owner and repository name

```sh
basalt.load --global 'github.com/rupa/z' 'z.sh'
```

If you do not pass a file, it will automatically source a `load.bash` at the root of the repository, if it exists

## Local context

Local environment variables are only valid within a Bash package (after `eval "$(basalt-package-init)"; basalt.package-init`)

### `basalt.package-load`

Loads all Basalt dependencies

```sh
basalt.package-load
```
