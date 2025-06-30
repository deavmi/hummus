hummus
======

[![DUB](https://img.shields.io/dub/v/hummus?color=%23c10000ff%20&style=flat-square)](https://code.dlang.org/packages/hummus) [![DUB](https://img.shields.io/dub/dt/hummus?style=flat-square)](https://code.dlang.org/packages/hummus) ![DUB](https://img.shields.io/dub/l/hummus?style=flat-square)

# Usage

Below is an example of how we can use a provider
to fill up the values within a complex data structure:

```d
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
    // private A si;
}

auto mc = MinhaConfiguracao();

auto ds = new DummySink();
fill(mc, ds);
writeln("Provider had requests for: ", ds._s.keys);

// show how the struct was filed
// up
writeln(mc);

assert(mc.porto == 443);
assert(mc.s.x == 10);
assert(mc.s.y == -10);
}
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
