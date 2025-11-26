hummus
======

Easy template-enabled configuration engine

[![DUB](https://img.shields.io/dub/v/hummus?color=%23c10000ff%20&style=flat-square)](https://code.dlang.org/packages/hummus) [![DUB](https://img.shields.io/dub/dt/hummus?style=flat-square)](https://code.dlang.org/packages/hummus) ![DUB](https://img.shields.io/dub/l/hummus?style=flat-square) [![D](https://github.com/deavmi/hummus/actions/workflows/d.yml/badge.svg)](https://github.com/deavmi/hummus/actions/workflows/d.yml)
[![Coverage Status](https://coveralls.io/repos/github/deavmi/hummus/badge.svg?branch=master)](https://coveralls.io/github/deavmi/hummus?branch=master)

# Usage

Below is an example of how we can use a provider
to fill up the values within a complex data structure:

```d
import  hummus.cfg : fill;
import std.stdio : writeln;

struct X
{
    private string p;
}

struct A
{
    private int x, y;
    private X z;
}

struct MinhaConfiguracao
{
    private string adres;
    private size_t porto;
    private A s;
}

auto mc = MinhaConfiguracao();

auto ds = new DummySink();
fill(mc, ds);

// show how the struct was filed
// up
writeln(mc);

// check values and make sure
// everything is there as
// expected
assert(mc.porto == 443);
assert(mc.s.x == 10);
assert(mc.s.y == -10);
```

Right at the end we can see how all the values would
have been filled out when we did `writeln(mc)`:

```
MinhaConfiguracao("v:adres", 443, A(10, -10, X("v:s.z.p")))
```

View the [full documentation](https://hummus.dpldocs.info/index.html).

## Providers

If you want to implement a provider then take a look
at the [documentation](https://hummus.dpldocs.info/hummus.provider.Provider.html) so you can see what you would
need to implement.

The providers that come with this package are:

1. `EnvironmentProvider`
  * This uses environment variables to provision
  * Module name is `hummus.providers.env`
2. `JSONProvider`
  * This uses a JSON file to provision
  * Module name is `hummus.providers.json`

### `EnvironmentProvider`

A name like `root.a` will be translated to
a search for an environment variable named
`ROOT__A`.

Read the [API](https://hummus.dpldocs.info/hummus.providers.env.html).

### `JSONProvider`

A provider which will look for JSON key-value pairs
based on matching them to the names of the fields in
the provided struct.

Struct fields which are of a struct-type themselves
are supported and are filled whenever json such as
`x.y` is encountered. This means `x` is some field
in the "outer" struct. Then because we have `x.y`,
`x` MUST be of a struct type. Then we access the field
named `y` in this "inner" struct.

Hence a name like `root.a` will be translated to
an access at `jsonObject["root"].a` (where `jsonObject`
is the root document).

Read the [API](https://hummus.dpldocs.info/hummus.providers.json.html).

# Development

## Testing

In order to run the full test suite use the following
command (or just `./test.sh`):

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
