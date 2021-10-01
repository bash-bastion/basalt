# Local Projects

TODO: WARNING: This is out of date

Similar to `npm`, `carto`, etc. `basalt` allows for the installation of packages on a per-project basis. Use `basalt.toml` for this

```sh
mkdir 'my-project' && cd 'my-project'

# Creating a 'basalt.toml' is required so basalt knows where
# the root of the project is
touch 'basalt.toml'
```

Let's take a look at the installed packages

```sh
$ basalt list
Info: Operating in context of local basalt.toml
```

So far, none are installed. Let's install [bash-args](https://github.com/hyperupcall/bash-args). To do this, modify `dependencies` in your `basalt.toml`

```toml
# basalt.toml
dependencies = [ "hyperupcall/bash-args" ]
```

Now, install it

```sh
$ basalt add --all
Info: Operating in context of local basalt.toml
Info: Adding all dependencies
Info: Adding 'hyperupcall/bash-args'
  -> Cloning Git repository
  -> Symlinking bin files
```

It now shows up in the `list` subcommand

```sh
$ basalt list
Info: Operating in context of local basalt.toml
github.com/hyperupcall/bash-args
  Branch: main
  Revision: 2087e87
  State: Up to date
```

You'll notice a `.basalt` directory has been created. Since the project is now installed, let's use it

Create a `script.sh` file

```sh
#!/usr/bin/env bash

# @file script.sh
# @brief Demonstration of the bash-args library

# Append to the PATH so we have access to `bash-args` in the PATH
PATH="$PWD/.basalt/bin:$PATH"

# Declare an associative array for storing the argument flags
declare -A args=()

# 'bash-args' requires that we use `source`, so it can
# set fields in the 'args' associative array
source bash-args parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

printf '%s\n' "Using port '${args[port]}'"
```

Cool, now let's try it

```sh
$ chmod +x './script.sh'
$ ./script.sh
Using port '3000'
$ ./script.sh --port 4000
Using port '4000'
```
