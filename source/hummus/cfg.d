/**
 * Automatic compile-time configuration
 * discovery and provisioning
 *
 * Authors: Tristan Brice Velloza Kildaire (deavmi)
 */
module hummus.cfg;

import std.traits : Fields, FieldNameTuple;
import niknaks.meta : isStructType, isClassType;

version(unittest)
{
    import gogga.mixins;
}

import std.string : format;
import niknaks.functional : Optional;
import hummus.provider;

version(unittest)
{
    import std.stdio : writeln;
}

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

    version(unittest)
    {
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
    }

    // Loop through each pair and process
    static foreach (c; 0 .. fn_s.length)
    {
        version(unittest)
        writeln("Exmine member '", fn_s[c], "'");

        version(unittest)
        writeln("Exmine member '", __traits(getMember, s, fn_s[c]), "'");

        // if the current member's type is
        // a struct-type
        static if (isStructType!(typeof(__traits(getMember, s, fn_s[c]))))
        {
            version(unittest)
                pragma(msg, "The '", fn_s[c], "' is a struct type");

            // recurse on this member (it is a struct type)
            fieldsOf(__traits(getMember, s, fn_s[c]), p, generateName(fn_s[c], r));
        }
        // todo: disallow class types
        else static if (isClassType!(typeof(__traits(getMember, s, fn_s[c]))))
        {
            pragma(msg, "We do not yet support class types, which '", fn_s[c], "' is");
            static assert(false);
        }
        else
        {
            version(unittest)
                pragma(msg, "The '", fn_s[c], "' is a primitive type");

            // ask provider for value, if it has one, then
            // attempt to assign it
            if (p.provide(generateName(fn_s[c], r)).isPresent())
            {
                // todo: catch failing to!(T)(V) call exception
                import std.conv : to;

                version(unittest)
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

/**
 * Given a structure and a provider this
 * will discover all the required fields
 * and then fill those fields with values
 * provided by the provider.
 *
 * The root name will prefix all names
 * as `<rootName>.`
 *
 * Params:
 *   structType = the structure
 *   p = the provider
 *   rootName = name of the root
 */
public void fill(T)(ref T structType, Provider p, string rootName)
{
    fieldsOf(structType, p, rootName);
}

/**
 * Given a structure and a provider this
 * will discover all the required fields
 * and then fill those fields with values
 * provided by the provider
 *
 * Params:
 *   structType = the structure
 *   p = the provider
 */
public void fill(T)(ref T structType, Provider p)
{
    fieldsOf(structType, p);
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
    fill(mc, ds);
    writeln("Provider had requests for: ", ds._s.keys);

    // show how the struct was filed
    // up
    writeln(mc);
}
