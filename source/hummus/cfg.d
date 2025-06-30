/**
 * Automatic compile-time configuration
 * discovery and provisioning
 */
module hummus.cfg;

import std.traits : Fields, FieldNameTuple;
import niknaks.meta : isStructType, isClassType;

import gogga.mixins;

import niknaks.functional : Optional;

import hummus.provider;

import std.stdio : writeln;
import std.string : format;

/**
 * Given a name and a root value
 * this will generate the name as
 * `<rootVal>.<n>` if and only if
 * `rootVal` is not empty. If it
 * is empty then the name is returned
 * as `n`, unchanged.
 *
 * Params:
 *   n = the name
 *   rootVal = the root value
 * Returns: the transformed name
 */
private string generateName(string n, string rootVal)
{
    if (rootVal.length)
    {
        return rootVal ~ "." ~ n;
    }
    return n;
}

/**
 * Generates the field names of the given
 * structure and fills them in with values
 * from the given provider.
 *
 * Params:
 *   s = the structure
 *   p = the provider for names
 */
package void fieldsOf(T)(ref T s, Provider p)
{
    // assume roots name is ""
    fieldsOf(s, p, "");
}

/**
 * This is a compile-time recursive
 * function that wil generate multiple
 * versions of itself in order to discover
 * the full structure of the struct
 * type `T`.
 *
 * The struct will be updated via `ref`
 * (via reference) and values will be
 * assigned to it via the provider `p`.
 *
 * In order for naming to be hierachial
 * a root value is passed along as an
 * auxillary piece of data
 *
 * Names will always be `fieldName`
 * and if in a struct then `structFieldName.fieldName`
 * and so on...
 *
 * Params:
 *   s = the structure
 *   p = the provider
 *   r = the root value
 */
package void fieldsOf(T)(ref T s, Provider p, string r) // todo: niknaks - is-struct check
if (isStructType!(T)())
{
    // compile time gen: assignment lines
    alias ft_s = Fields!(T);
    alias fn_s = FieldNameTuple!(T);

    writeln("Struct on entry: ", s);
    scope (exit)
    {
        writeln("Struct on exit: ", s);
    }

    writeln("Fields of struct: '", __traits(identifier, T), "'");
    scope (exit)
    {
        writeln("Processed '", __traits(identifier, T), "'");
    }

    // Loop through each pair and process
    static foreach (c; 0 .. fn_s.length)
    {
        writeln("Exmine member '", fn_s[c], "'");

        // assignment would look like below
        // __traits(getMember, s, fn_s[c]) = __traits(getMember, s, fn_s[c]);
        writeln("Exmine member '", __traits(getMember, s, fn_s[c]), "'");

        // if the current member's type is
        // a struct-type
        // todo: try use below
        // mixin("alias _mem",c) = T;
        static if (isStructType!(typeof(__traits(getMember, s, fn_s[c]))))
        {
            pragma(msg, "The '", fn_s[c], "' is a struct type");
            // pragma(msg, fn_s[c]~"."~__traits(identifier, __traits(getMember, s, fn_s[c])));
            // sk.sink(fn_s[c]~"."~__traits(identifier, __traits(getMember, s, fn_s[c])));

            // recurse on each struct member
            fieldsOf(__traits(getMember, s, fn_s[c]), p, generateName(fn_s[c], r));
            // foreach (fn_inner; fieldsOf(__traits(getMember, s, fn_s[c]), p, generateName(fn_s[c], r)))
            // {
            // _fs ~= fn_s[c] ~ "." ~ fn_inner;

            // mixin("s."~fn_s[c]) = ;

            // p.provide(fn_s[c] ~ "." ~ fn_inner);
            // writeln("Provided: ", p.provide(fn_s[c] ~ "." ~ fn_inner)); // todo: access here for saving
            // }
        }
        // todo: disallow class types
        else static if (isClassType!(typeof(__traits(getMember, s, fn_s[c]))))
        {
            pragma(msg, "We do not yet support class types, which '", fn_s[c], "' is");
            static assert(false);
        }
        else
        {
            pragma(msg, "The '", fn_s[c], "' is a primitive type");

            // ask provider for value, if it has one, then
            // attempt to assign it
            // auto opt = p.provide(fn_s[c]);
            // if(opt) fixme: make that work
            // todo: find a way to make temp vars
            // if(p.provide(fn_s[c]).isPresent())
            if (p.provide(generateName(fn_s[c], r)).isPresent())
            {
                // todo: catch failing to!(T)(V) call exception
                import std.conv : to;

                DEBUG(format("Trying to convert '%s'", p.provide(generateName(fn_s[c], r)).get()));
                __traits(getMember, s, fn_s[c]) = to!(
                    typeof(__traits(getMember, s, fn_s[c]))
                )(
                    p.provide(generateName(fn_s[c], r)).get()
                );
            }

        }
    }
}

version (unittest)
{
    import std.stdio : writeln;
    import std.string : format;

    class DummySink : Provider
    {
        bool[string] _s;
        public bool provideImpl(string n, ref string v)
        {
            _s[n] = true;
            if (n == "adress")
            {
                return false;
            }
            else if (n == "porto")
            {
                v = "443";
                return true;
            }
            else if (n == "s.x")
            {
                v = "10";
                return true;
            }
            else if (n == "s.y")
            {
                v = "-10";
                return true;
            }
            // todo: disable below for conv error as it gets
            // the value below whioch fails to convert
            // else if

            v = format("v:%s", n);
            return true;
        }
    }
}

/**
 * Tests the discovery and filling
 * process on a complex structure
 * which fields that are of structure
 * types too (nested structures).
 */
unittest
{
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
    fieldsOf(mc, ds, "");
    writeln("Provider had requests for: ", ds._s.keys);

    // show how the struct was filed
    // up
    writeln(mc);
}
