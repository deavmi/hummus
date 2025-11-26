/** 
 * JSON-based provider
 *
 * You should use this when
 * you want to fill up your
 * config with values stored
 * in a string containing
 * JSON-encoded data
 *
 * Authors: Tristan Brice Velloza Kildaire (deavmi)
 */
module hummus.providers.json;

import hummus.provider : Provider;
import std.json : JSONValue, JSONType;
import niknaks.json : traverseTo;

// todo: remove
import std.stdio;

/**
 * A provider which will look for
 * JSON key-value pairs based on
 * matching them to the names of the
 * fields in the provided struct.
 *
 * Struct fields which are of
 * a struct-type themselves are
 * supported and are filled 
 * whenever json such as `x.y`
 * is encountered. This means `x`
 * is some field in the "outer"
 * struct. Then because we have
 * `x.y`, `x` MUST be of a struct
 * type. Then we access the field
 * named `y` in this "inner" struct
 */
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