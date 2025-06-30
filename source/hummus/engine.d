/**
 * An engine for provisioning via
 * multiple providers
 */
module hummus.engine;

import hummus.provider;
import gogga.mixins; // todo: make part of optional compilation
import std.string : format;

// Else it keeps trying to call to the
// one in the `Engine` itself
import hummus.cfg : fill_outer = fill;

/**
 * The `Engine` is a provider which
 * allows multiple _other_ providers
 * to be attached to it.
 *
 * During provisioning if a name
 * is found in a provider then it
 * is returned, else the next provider
 * is checked.
 *
 * The order in which providers are
 * attached is important as that
 * is the order in which they will
 * be queried
 */
public class Engine : Provider
{
    private Provider[] _ps;

    /**
     * Constructs a new engine with
     * no providers attached
     */
    this()
    {

    }

    /**
     * Attach a provider
     *
     * Params:
     *   p = the provider to attach
     */
    public void attach(Provider p)
    {
        if (p is null)
        {
            // todo: check
            return;
        }
        this._ps ~= p;

        DEBUG(format("Attached provider '%s'", p));
    }

    protected bool provideImpl(string n, ref string v)
    {
        foreach (Provider p; this._ps)
        {
            auto pr_opt = p.provide(n);
            if (pr_opt.isPresent())
            {
                v = pr_opt.get();
                return true;
            }
        }
        return false;
    }

    /**
     * Given a structure this will fill
     * it up with values by querying
     * the attached provider(s)
     *
     * Params:
     *   structInstance = the structure
     * to provision
     */
    public void fill(T)(ref T structInstance)
    {
        fill_outer(structInstance, this);
    }
}

version (unittest)
{
    class DP1 : Provider
    {
        protected bool provideImpl(string n, ref string v)
        {
            if (n == "Key1")
            {
                v = "Value1";
                return true;
            }

            return false;
        }
    }

    class DP2 : Provider
    {
        protected bool provideImpl(string n, ref string v)
        {
            if (n == "Key2")
            {
                v = "Value2";
                return true;
            }

            return false;
        }
    }
}

unittest
{
    auto e = new Engine();

    auto opt1 = e.provide("Key1");
    auto opt2 = e.provide("Key2");
    assert(opt1.isEmpty());
    assert(opt1.isEmpty());

    e.attach(new DP1());
    opt1 = e.provide("Key1");
    opt2 = e.provide("Key2");
    assert(opt1.isPresent());
    assert(opt1.get() == "Value1");
    assert(opt2.isEmpty());

    e.attach(new DP2());
    opt1 = e.provide("Key1");
    opt2 = e.provide("Key2");
    assert(opt1.isPresent());
    assert(opt1.get() == "Value1");
    assert(opt2.isPresent());
    assert(opt2.get() == "Value2");

    struct F
    {
        string Key1;
        string Key2;
    }

    auto f = F();
    e.fill(f);
    assert(f.Key1 == "Value1");
    assert(f.Key2 == "Value2");
}
