# bash-toml

A kickass Toml parser written in pure Bash

The plan is to fully support TOML v1.0.0

## Assumptions of Quick

- The `quick_` methods ony parse [a subset of toml](https://github.com/hyperupcall/toml-subset)

## Support

Support is generally limited at the moment

- Construct: Comment
- Construct: Key
- Value: String (basic)
- Value: String (literal)

### Not Yet Supported

- Value: String (multi-line basic)
- Value: String (multi-line literal)
- Value: Integer
- Value: Float
- Value: Boolean
- Value: Offset Date-Time
- Value: Local Date-Time
- Value: Local Date
- Value: Local Time
- Value: Array
- Value: Inline Table
- Construct: Table
- Construct Array of Tables
