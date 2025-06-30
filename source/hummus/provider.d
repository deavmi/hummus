/**
 * Definition for the provider interface
 *
 * Authors: Tristan Brice Velloza Kildaire (deavmi)
 */
module hummus.provider;

version(unittest)
{
    import gogga.mixins;
    import std.string : format;
}

import niknaks.functional : Optional;

/**
 * Describes a provider of
 * values which, when requested
 * by a name will yield the
 * corresponding value
 */
public interface Provider
{
    /**
     * The implementation method for a provider.
     * This must return `true` when an entry by
     * the name of `n` is found and then set its
     * associated value via `v_out`. Otherwise,
     * `false` must be returned.
     *
     * Params:
     *   n = the name being queried
     *   v_out = the associated value (if found)
     * Returns: `true` if found, `false` otherwise
     */
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
        version(unittest)
            DEBUG(format("Looking up configuration entry for '%s'...", name));

        string _v;
        if (!provideImpl(name, _v))
        {
            version(unittest)
                ERROR(format("No value mapping for '%s'", name));
            return Optional!(string).empty();
        }

        version(unittest)
            INFO(format("Mapped name '%s' to value '%s'", name, _v));
        return Optional!(string)(_v);
    }
}