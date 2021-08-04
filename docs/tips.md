# Tips

## Better Sourcing

If you share your dotfiles across multiple machines, this means that you may not have bpm installed or have the package `rupa/z` installed on all machines. It's recommend that you check this before actual sourcing (this isn't specific to bpm, but just good to do anyways)

```sh
# If the command 'bpm' was found in the PATH
if command -v bpm >/dev/null 2>&1; then
  if pkg_dir="$(bpm --global package-path rupa/z)" && [ -n "$pkg_dir" ]; then
    source "$pkg_dir/z.sh"
  fi
fi
```
