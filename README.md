hummus
======

[![DUB](https://img.shields.io/dub/v/hummus?color=%23c10000ff%20&style=flat-square)](https://code.dlang.org/packages/hummus) ![DUB](https://img.shields.io/dub/dt/hummus?style=flat-square) ![DUB](https://img.shields.io/dub/l/hummus?style=flat-square)

# Usage

TODO: Ad something about environment provider
and the transformation it uses

```
V=1 I__Z=2 dub test
```

# Development

## Testing

In order to run the full test suite use the following
command:

```d
V=1 I__Z=2 dub test
```

The reason for the declaration of the environment
variables `V=1 I__Z=2` is because onfe of the tests
is for the `EnvironmentProvider` which searches
for environment variables, and in particular its
unittest looks for those two.

## License

Licensed under the LGPL-2.0-only .
