module hummus.engine;


// todo: some engine with multiple providers that
// can be queried. It itself can be placed into the
// discovery method or not. I will have to decide.

// it probably can be if we model it, itself, as a provider

import hummus.provider;
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

    public void fill(T)(ref T structInstance)
    {
    	fill_outer(structInstance, this);
    }
}

private alias fill_outer = hummus.engine.fill;

version(unittest)
{
    class DP1 : Provider
    {
        protected bool provideImpl(string n, ref string v)
        {
            if(n == "Key1")
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
            if(n == "Key2")
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



public void fill(T)(ref T structType, Provider p)
// todo: isStructType
{
    import hummus.cfg : fieldsOf;
    
    fieldsOf(structType, p);
}
