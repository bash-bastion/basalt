# Install Local Packages

Rather than installing from a remote Git repository, you may want to install a package on your machine. Use `link` for this

When using `link`, pass in the directories you wish to link

```sh
bpm --global link ~/Documents/projects/cool-project
```

When you link a project, it shows up under the `local` namespace, as seen by `list`

```sh
$ bpm --global --format=simple list
local/cool-project
```
