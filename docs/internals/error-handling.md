# Error Handling

TODO

Error handling, should work consistently across applications. The following is a proposal. It is recommended to _not_ enable `nounset`. `errexit` _may_ be enabled. `pipefail` _should_ be enabled. `errtrace` and `functrace` may be of interest as well.

## Function

```sh
fn() {
  local curl_output=
  if curl_output="$(curl -LSsfo "$2" "$1" 2>&1)"; then
    :
  else
    printf -v ERR 'Error: %s\n\tCurl output: %s' "Failed to fetch content from the internet" "$curl_output"

    # Avoid '! curl ...' because that will muck with '$?'
    return $?
  fi
}

if fn 'https://google.com' 'file.html'; then
  cat 'file.html'
else
  printf '%s' "$ERR"
fi
```
