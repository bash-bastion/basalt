# bash-core

Core functions for any Bash program

## Summary

The following is a brief overview of the available functions. See [api.md](./docs/api.md) for more details

### `trap`

Add or remove multiple functions at a time to any set of signals. Without these, it is impossible to trap a signal without erasing a previous one

- `core.trap_add`
- `core.trap_remove`

### `shopt`

Enable or disable a shell option. Enabling a shell option adds it to a hidden stack. When that shell option is no longer needed, it should be removed by popping it from the stack

- `core.shopt_push`
- `core.shopt_pop`

### `err`

It can look redundant (compared to `if ! fn; then :; fi`) to define error functions, but it can help make errors a bit more safe in larger applications, since you don't have to worry about a caller forgetting to `if ! fn` or `fn ||` (and terminating the script if `set -e`). It also makes it easier to communicate specific error codes and helps separate between calculated / expected errors and unexpected errors / faults

- `core.err_set`
- `core.err_clear`
- `core.err_exists`

### `print`

- `core.print_stacktrace`
- `core.print_error`
- `core.print_warn`
- `core.print_info`

The function `core.print_stacktrace` prints the stack trace. It is recommended to use this with `core.trap_add` (see [example](./docs/api.md#coreprint_stacktrace))

### Misc

Miscellaneous functions

- `core.panic()`
- `core.should_output_color()`

This is what it may look like

```txt
Stacktrace:
  in core.stacktrace_print (/storage/ur/storage_home/Docs/Programming/repos/Groups/Bash/bash-core/.hidden/test.sh:0)
  in err_handler (/storage/ur/storage_home/Docs/Programming/repos/Groups/Bash/bash-core/.hidden/test.sh:36)
  in fn3 (/storage/ur/storage_home/Docs/Programming/repos/Groups/Bash/bash-core/.hidden/test.sh:48)
  in fn2 (/storage/ur/storage_home/Docs/Programming/repos/Groups/Bash/bash-core/.hidden/test.sh:53)
  in fn (/storage/ur/storage_home/Docs/Programming/repos/Groups/Bash/bash-core/.hidden/test.sh:57)
```

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-core
```
