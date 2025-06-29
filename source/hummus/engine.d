module hummus.engine;


// todo: some engine with multiple providers that
// can be queried. It itself can be placed into the
// discovery method or not. I will have to decide.

// it probably can be if we model it, itself, as a provider

import hummus.cfg : Provider;
import gogga.mixins;
import std.string : format;

public class Engine : Provider
{
    private Provider[] _ps;

    this()
    {

    }

    public void attach(Provider p)
    {
        if(p is null)
        {
            // todo: check
            return;
        }
        this._ps ~= p;

        DEBUG(format("Attached provider '%s'", p));
    }

    protected bool provideImpl(string n, ref string v)
    {
        foreach(Provider p; this._ps)
        {
            auto pr_opt = p.provide(n);
            if(pr_opt.isPresent())
            {
                v = pr_opt.get();
                return true;
            }
        }
        return false;
    }
}