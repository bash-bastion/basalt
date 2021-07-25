
## Local Package Development

If you are working on a project, and want to pull in a dependency, say [bash-args](https://github.com/eankeen/bash-args), the workflow is similar to installing packages globally

To use the packages, simply append to the `PATH` variable in your script entrypoint (`script.sh` in the example below). Note that exporting it isn't required because it's already an exported variable

```sh
mkdir 'my-project' && cd 'my-project'

# Creating a 'bpm.toml' is required so bpm knows where
# the root of the project is
touch 'bpm.toml'

bpm add 'eankeen/bash-args'

cat > 'script.sh' <<-"OUTEREOF"
#!/usr/bin/env bash

PATH="$PWD/bpm_packages/bin:$PATH"

declare -A args=()

# 'bash-args' requires that we use `source`
source bash-args parse "$@" <<-"EOF"
@flag [port.p] {3000} - The port to open on
EOF

echo "Using port '${args[port]}'"
OUTEREOF

chmod +x './script.sh'
./script.sh # Using port '3000'
./script.sh --port 4000 # Using port '4000'
```
