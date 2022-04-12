# bash-term

Bash library for terminal escape sequences

## Summary

This library was created to be a _fast_ alternative to `tput`. It includes a `btput` function to emulate the most common features of `tput` (without exec overhead). It also sports a more intuitive interface with names like `term.erase_line`, etc.

## Installation

Use [Basalt](https://github.com/hyperupcall/basalt), a Bash package manager, to add this project as a dependency

```sh
basalt add hyperupcall/bash-tty
```

## References

- [vtasni.html](https://www2.ccs.neu.edu/research/gpc/VonaUtils/vona/terminal/vtansi.htm)
- [asnci-escapes](https://github.com/sindresorhus/ansi-escapes/blob/main/index.js)
