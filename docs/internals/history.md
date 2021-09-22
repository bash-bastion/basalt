# History

Basalt originally started out as a fork of [Basher](https://github.com/basherpm/basher). I liked the behavior of Basher (moreso compared to `bpkg`), but there were a few features I wanted to add. This includes the ability to download multiple packages at once and making the program more compliant to the XDG Base Directory Specification

Although some of my features were merged, I wanted to improve the config format by replacing the `package.sh` with TOML configuration, along with improving the code quality and style to my liking. At around this time, I forked the project, calling it `neobasher`, then quickly renamed to `bpm` once my modifications became more significant

I essentially rewrote most of the codebase, authoring an additional ~100 tests. Some of the features at this point included

- Support for a `bpm.toml` file (in addition to backwards-compatible `package.sh` support)
- Substantiallly better help output
- Completion scripts
- Support for installing many more repositories
- Support for installing transitive dependencies
- Over 250+ tests

Although the code was heavily tested, I didn't really like _how_ packages were installed. It was inefficient and had the potential for bugs. When I had this realization, I decided to essentially start from scratch again, coding the design that is implemented today. I threw out the 250+ custom tests, implementations of commands, and nearly everything with the exception of a few low-level parsing functions. Contemporaneously, I renamed the project to `basalt`, and worked on the from-scratch implementation in a branch called `wip` until it was subsequently merged into `main`
