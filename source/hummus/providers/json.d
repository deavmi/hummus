module hummus.providers.json;

import hummus.provider : Provider;
import std.json : JSONValue, JSONType;
import niknaks.json : traverseTo;

public class JSONProvider : Provider
{
    import std.json : parseJSON, JSONException;

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
        // todo: check return value for nullity
        JSONValue* f_node = traverseTo(n, &this._j);

        // todo: value conversion here
        if(f_node is null)
        {
            return false;
        }

        string s_out;
        if(jsonNormal(f_node, s_out))
        {
            writeln("found JSON node toString(): ", s_out);
            v = s_out;
            return true;
        }
        else
        {
            return false;
        }
    }
}

private bool jsonNormal(JSONValue* i, ref string o)
{
    auto t = i.type();
    if(t == JSONType.string)
    {
        o = i.str();
        return true;
    }
    else if(t == JSONType.ARRAY)
    {
        writeln("'", i, "' is an array type, these are unsupported");
        return false;
    }
    // todo: disallow array types and object types
    else
    {
        o = i.toString();
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
    struct Inner
    {
        int prop;
        int k;
    }

    struct Basic
    {
        string name;
        ulong age;
        Inner x;
        string bad;
    }

    auto cfg = Basic();
    writeln("Before provisioning: ", cfg);

    // input json
    string json = `
    {
        "name": "Tristan Brice Velloza Kildaire",
        "age": 25,
        "x": {
            "prop": 2
        },
        "bad": ["", 2]
    }
    `;

    // create a new JSON provider with the
    // input JSON
    fieldsOf(cfg, new JSONProvider(json));

    assert(cfg.name == "Tristan Brice Velloza Kildaire");
    assert(cfg.age == 25);
    assert(cfg.x.prop == 2);

    // it is not present (in the JSON) hence it should
    // never be set in our struct
    assert(cfg.x.k == cfg.x.k.init);
    assert(cfg.bad.length == 0);
}