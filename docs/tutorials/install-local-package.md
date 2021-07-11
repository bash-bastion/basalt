# Install Local package

There are cases where you would want to install a package that is on your machine, rather than from an online code repository. This is what the `link` command is for

Note that the directory you specify _must_ be a Git repository

When using `link`, pass in the directory (or directories) you wish to link

```sh
bpm link ~/Documents/projects/cool-project
```

When you link a project, it shows up under the `local` namespace, as seen by `list`

```sh
$ bpm list
local/cool-project
```
