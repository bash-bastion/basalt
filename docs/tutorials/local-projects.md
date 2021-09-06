# Local Projects

Similar to `npm`, `carto`, etc. `bpm` allows for the installation of packages on a per-project basis. Use `bpm.toml` for this

```sh
mkdir 'my-project' && cd 'my-project'

# Creating a 'bpm.toml' is required so bpm knows where
# the root of the project is
touch 'bpm.toml'
```

Let's take a look at the installed packages

```sh
$ bpm list
Info: Operating in context of local bpm.toml
```

So far, none are installed. Let's install [bash-args](https://github.com/hyperupcall/bash-args). To do this, modify `dependencies` in your `bpm.toml`

```toml
# bpm.toml
dependencies = [ "hyperupcall/bash-args" ]
```

Now, install it

```sh
$ bpm add --all
Info: Operating in context of local bpm.toml
Info: Adding all dependencies
Info: Adding 'hyperupcall/bash-args'
  -> Cloning Git repository
  -> Symlinking bin files
```

It now shows up in the `list` subcommand

```sh
$ bpm list
Info: Operating in context of local bpm.toml
github.com/hyperupcall/bash-args
  Branch: main
  Revision: 2087e87
  State: Up to date
```

You'll notice a `bpm_packages` directory has been created. Since the project is now installed, let's use it

Create a `script.sh` file

```sh
#!/usr/bin/env bash

# @file script.sh
# @brief Demonstration of the bash-args library

# Append to the PATH so we have access to `bash-args` in the PATH
PATH="$PWD/bpm_packages/bin:$PATH"

# Declare an associative array for storing the argument flags
declare -A args=()

# 'bash-args' requires that we use `source`, so it can
# set fields in the 'args' associative array
source bash-args parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

echo "Using port '${args[port]}'"
```

Cool, now let's try it

```sh
$ chmod +x './script.sh'
$ ./script.sh
Using port '3000'
$ ./script.sh --port 4000
Using port '4000'
```
