module hummus.providers.json;

import hummus.provider : Provider;

public class JSONProvider : Provider
{
    import std.json : JSONValue, parseJSON, JSONException, JSONType;

    private JSONValue _j;

    this(string json)
    {
        // todo: handle exceptions in non-library specific way
        // OR require they parse in the JSONValue - that is
        // library-dependent tho
        this._j = parseJSON(json);
    }

    protected bool provideImpl(string n, ref string v)
    {
        import std.stdio : writeln;
        string[] c;
        if(dotExtract(n, c) == false)
        {
            writeln("direct access for: ", n);

            JSONValue* p = n in this._j;
            if(p)
            {
                string finalV;

                // todo: bail on unsupported types

                // de-stringatize if it is a JSON string
                if(p.type() == JSONType.string)
                {

                    // finalV = p.str()[]
                }
                else
                {
                    finalV = p.toString();
                }
                // import std.string : strip
                // todo: value must be vconverte here
                writeln("finalV: ", finalV);

                v = finalV;
                return true;
            }
            else
            {
                return false;
            }

            pragma(msg, typeof(p));
        }
        else
        {
            writeln("Access path: ", c);
        }

        // todo: use dot-explorer on the JSONValue
        return true;
    }
}

private bool dotExtract(string i, ref string[] o)
{
    import std.string : split;

    auto cmps = split(i, ".");

    if(cmps.length == 1)
    {
        return false;
    }
    else
    {
        o = cmps;
        return true;
    }
}

private version(unittest)
{
    import hummus.cfg : fieldsOf;
    import std.stdio : writeln;
}

unittest
{
    struct Basic
    {
        string name;
        ulong age;
    }

    auto cfg = Basic();
    writeln("Before provisioning: ", cfg);

    string json = `
    {
        "name": "Tristan Brice Velloza Kildaire",
        "age": 25
    }
    `;



    // todo: state what should be present
    // create a new JSON provider with the
    // input JSON
    fieldsOf(cfg, new JSONProvider(json));

    // assert(cfg.name == "Tristan Brice Velloza Kildaire");
    assert(cfg.age == 25);
}