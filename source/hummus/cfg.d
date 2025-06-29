module hummus.cfg;

import std.traits : Fields, FieldNameTuple;
import niknaks.meta : isStructType, isClassType;

import gogga.mixins;

import niknaks.functional : Optional;

/**
 * Describes a provider of
 * values which, when requested
 * by a name will yield the
 * corresponding value
 */
public interface Provider
{
    import std.string : format;
    import std.stdio : writeln;

    // todo: rename, get
    protected bool provideImpl(string n, ref string v_out);

    /**
     * Provides us the value that maps
     * to the given name
     *
     * Params:
     *   name = the name of the value
     * to lookup
     * Returns: an `Optional` containing
     * the value (if a mapping exists)
     */
    public final Optional!(string) provide(string name)
    {
        DEBUG(format("Looking up configuration entry for '%s'...", name));

        string _v;
        if(!provideImpl(name, _v))
        {
            ERROR(format("No value mapping for '%s'", name));
            return Optional!(string).empty();
        }

        INFO(format("Mapped name '%s' to value '%s'", name, _v));
        return Optional!(string)(_v);
    }
}

//
// this will discover everything in
// the struct and then it needs to
// sink it into some sort of interface
// that implements this
//
private string[] fieldsOf(T)(T s, Provider p) // todo: niknaks - is-struct check
if (isStructType!(T)())
{
    string[] _fs;

    // compile time gen: assignment lines
    alias ft_s = Fields!(T);
    alias fn_s = FieldNameTuple!(T);

    // Loop through each pair and process
    static foreach (c; 0 .. fn_s.length)
    {
        // writeln(p.provide(fn_s[c]));
        p.provide(fn_s[c]);
        _fs ~= fn_s[c];

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
            foreach (fn_inner; fieldsOf(__traits(getMember, s, fn_s[c]), p))
            {
                _fs ~= fn_s[c] ~ "." ~ fn_inner;

                // mixin("s."~fn_s[c]) = ;

				p.provide(fn_s[c] ~ "." ~ fn_inner);
                // writeln("Provided: ", p.provide(fn_s[c] ~ "." ~ fn_inner)); // todo: access here for saving
            }
        }
        // todo: disallow class types
        else static if(isClassType!(typeof(__traits(getMember, s, fn_s[c]))))
        {
        	pragma(msg, "We do not yet support class types, which '", fn_s[c], "' is");
        	static assert(false);
        }
        else
        {
        	pragma(msg, "The '", fn_s[c], "' is a primitive type");
        }
    }

    return _fs;
}

version (unittest)
{
    import std.stdio : writeln;
}

version (unittest)
{
    import std.stdio : writeln;
    import std.string : format;

    class DummySink : Provider
    {
        public bool provideImpl(string n, ref string v)
        {
            if(n == "porto")
            {
                return false;
            }

            v = format("v:%s", n);
            return true;
        }
    }
}

unittest
{
    struct X
    {
        private int p;
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
    auto s = fieldsOf(mc, ds);
    writeln(s);
}
