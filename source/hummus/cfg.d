module hummus.cfg;

import std.traits : Fields, FieldNameTuple;
import niknaks.meta : isStructType;

private void go(ft, string fn)()
{
	pragma(msg, "Processing entry '", fn, "' with type '", ft, "'");

	// static if(isStructType!(ft))
	// {
		// fieldsOf(ft);
	// }
}

public interface Sink
{
	public void sink(string name);

	// public final void sink(T)(string name)
	// {
		// import std.conv : to;
		// sink(name, to!(string)(value));
	// }
}

private void sinkStruct()
// todo: struct check
{
	
}

//
// this will discover everything in
// the struct and then it needs to
// sink it into some sort of interface
// that implements this
//
private string[] fieldsOf(T)(T s, Sink sk)
// todo: niknaks - is-struct check
if(isStructType!(T)())
{
	string[] _fs;

	// compile time gen: assignment lines
	
	alias ft_s = Fields!(T);
	alias fn_s = FieldNameTuple!(T);

	// Loop through each pair and process
	static foreach(c; 0..fn_s.length)
	{
		sk.sink(fn_s[c]);
		_fs ~= fn_s[c];
		go!(ft_s[c], fn_s[c]);

		// if the current member's type is
		// a struct-type
		// mixin("alias _mem",c) = T;
		static if(isStructType!( typeof( __traits(getMember, s, fn_s[c]) ) ) )
		{
			pragma(msg, "The '", fn_s[c], "' is a struct type");
			// pragma(msg, fn_s[c]~"."~__traits(identifier, __traits(getMember, s, fn_s[c])));
			sk.sink(fn_s[c]~"."~__traits(identifier, __traits(getMember, s, fn_s[c])));

			// static foreach(c; 0..FieldNameTuple!(typeof(__traits(getMember, s, fn_s[c]))).length)
			// {
				// fieldsOf(__traits(getMember, s, fn_s[c]), sk);
			// }

			foreach(fn_inner; fieldsOf(__traits(getMember, s, fn_s[c]), sk))
			{
				_fs ~= fn_s[c]~"."~fn_inner;	
			}
		}
	}
	
	return _fs;
}

version(unittest)
{
	import std.stdio : writeln;
}

version(unittest)
{
	import std.stdio : writeln;
	import std.string : format;
	class DummySink : Sink
	{
		public void sink(string n)
		{
			writeln("name: ", n);
		}
	}
}

unittest
{
	struct X
	{
		private int p;
	}

	struct A
	{
		private int x, y;
		private X z;		
	}

	struct MinhaConfiguracao
	{
		private string adres;
		private size_t porto;
		private A s;
		private A si;
	}
	auto mc = MinhaConfiguracao();

	auto ds = new DummySink();
	auto s = fieldsOf(mc, ds);
	writeln(s);
}
