module hummus.env;

import hummus.cfg : Provider;
import std.process : environment;

/** 
 * A provider which will look for
 * environment variables based
 * on a _transformed_ version of
 * their name. This transformation
 * replaces all `.` with two underscores -
 * `__`.
 */
public class EnvironmentProvider : Provider
{
    // todo: can '.''s work - I think so?
    protected bool provideImpl(string n, ref string v)
    {
        import std.string : replace;
        auto trans_n = replace(n, ".", "__");
        
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
}

unittest
{
    struct Inner
    {
        string z;
    }
    
    struct Cfg
    {
        string v;
        Inner i;
    }
    
    auto cfg = Cfg();
    
    // envvars `v` and `i.z` should be present
    fieldsOf(cfg, new EnvironmentProvider());
}