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
        // todo: check return value for nullity
        JSONValue* f_node = traverseTo(n, &this._j);

        // todo: value conversion here
        if(f_node is null)
        {
            return false;
        }

        string s = jsonNormal(f_node);
        writeln("found JSON node toString(): ", s);
        v = s;
        return true;
    }
}

import std.json : JSONValue;

import std.json : JSONType;
private string jsonNormal(JSONValue* i)
{
    if(i.type() == JSONType.string)
    {
        string s = i.str();
        return s;
    }
    // todo: disallow array types and object types
    else
    {
        return i.toString();
    }
}

// todo: this belongs in the niknaks library
private JSONValue* traverseTo(string path, JSONValue* start)
{
    import std.string : split, indexOf;

    // no dots `.` in the name
    if(indexOf(path, ".") < 0)
    {
        JSONValue* p = path in *start;

        return p;
    }
    // if there are dots present like `x.y`
    else
    {
        string[] cmps = split(path, ".");

        JSONValue* root = cmps[0] in *start;

        // todo: range check?
        string[] rem = cmps[1..$];
        import std.string : join;

        return traverseTo(join(rem, "."), root);
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

    assert(cfg.name == "Tristan Brice Velloza Kildaire");
    assert(cfg.age == 25);
}