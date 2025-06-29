module hummus.provider;

// todo: make these built in to only non-release builds
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
