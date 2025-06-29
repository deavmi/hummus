module hummus.env;

import hummus.cfg : Provider;
import std.process : environment;

/** 
 * A provider which will look for
 * environment variables based
 *on their name
 */
public class EnvironmentProvider : Provider
{
    // todo: can '.''s work - I think so?
    protected bool provideImpl(string n, ref string v)
    {
        // todo: switch to nothrow version
        try
        {
            v = environment[n];
            return true;
        }
        catch(Exception e)
        {
            return false;
        }
    }
}