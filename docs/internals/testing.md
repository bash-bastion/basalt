# Testing

What is with '\_' in

```sh
test_util.init_app 'project-foxtrot' '.' \
  "dependencies = ['file://./subpkg']" \
  '_'
```

Makes tests go faster since basalt does less processing on the basalt.toml
