# Available

Basalt provides various functions in certain contexts. This page details them

### Global Context

When executing `eval "$(basalt global init bash)"`, Basalt makes available the following functions

## basalt.load

This sources a particular file of a particular package

For example, the below example sources the `z.sh` file that is present at the root of [rupa/z](https://github.com/rupa/z). Note that you must pass in the website, as well as the repository owner and repository name

```sh
basalt.load --global 'github.com/rupa/z' 'z.sh'
```

If you do not pass a file, it will automatically source a `load.bash` at the root of the repository, if it exists

### Local context

When executing `eval "$(basalt-package-init)"`, Basalt makes available the following functions, in addition to functions you would normally find in the global context
