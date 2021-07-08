# Recepies

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
bpm link ./directory
```

The `link` command will install the dependencies of the local package.
You can prevent that with the `--no-deps` option

### Sourcing files from a package into current shell

`bpm` provides an `include` function that allows sourcing files into the
current shell. After installing a package, you can run:

```sh
include username/repo lib/file.sh
```
