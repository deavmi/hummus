/**
 * Environment variable-based
 * provider.
 *
 * You should use this if you
 * intend on filling up your
 * config with values that are
 * available as environment
 * variables
 *
 * Authors: Tristan Brice Velloza Kildaire (deavmi)
 */
module hummus.providers.env;

import hummus.provider : Provider;
import std.process : environment;

/**
 * A provider which will look for
 * environment variables based
 * on a _transformed_ version of
 * their name.
 *
 * This transformation replaces all
 * `.` with a character of your
 * choice (default is `__`) and
 * also ensures all parts of the
 * name are upper-case.
 */
public class EnvironmentProvider : Provider
{
	private string _dp;

	/**
	 * Constructs a new environment
	 * provider and uses the given
	 * token to replace all occurrences
     * of `.` in names
     *
     * Params:
     *   dotReplace = the replaceent token
     */
	this(string dotReplace)
	{
		this._dp = dotReplace;
	}

	/**
	 * Constructs a new environment
     * provider and uses the `__`
     * token as the replacement
     * token
     */
	this()
	{
		this("__");
	}

    /**
     * Implementation
     */
    protected bool provideImpl(string n, ref string v)
    {
		// upper-case everything
		import std.string : toUpper;
		auto trans_n = toUpper(n);

    	// replace `.` with `_dp`
        import std.string : replace;
        trans_n = replace(trans_n, ".", this._dp);

        // todo: switch to nothrow version
        try
        {
            v = environment[trans_n];
            return true;
        }
        catch(Exception e)
        {
            return false;
        }
    }
}

private version(unittest)
{
    import hummus.cfg : fieldsOf;
    import std.stdio : writeln;
}

unittest
{
	writeln();
	scope(exit)
	{
		writeln();
	}

    struct Inner
    {
        int z;
    }

    struct Cfg
    {
        string v;
        Inner i;
    }

    auto cfg = Cfg();
    writeln("Before provisioning: ", cfg);

    // envvars `v` and `i.z` should be present
    fieldsOf(cfg, new EnvironmentProvider());

	writeln("After provisioning: ", cfg);

    assert(cfg.v == "1");
    assert(cfg.i.z == 2);
}
