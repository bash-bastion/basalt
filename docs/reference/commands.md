# Commands

## `basalt add`

Add a local dependency to your project. The following types of dependencies are supported

### Local

Local dependencies begin with `file://` in the `basalt.toml`. When adding, the dependency must begin with `/` or `./`

### Remote

Remote dependencies begin with `https://` in the `basalt.toml`. The following forms are accepted:

- `hyperupcall/bash-object`
- `github.com/hyperupcall/bash-object`
- `https://github.com/hyperupcall/bash-object`
