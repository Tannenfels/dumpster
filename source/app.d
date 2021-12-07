module dumpster.app;

import std.stdio;
import socketListener;
import std.conv;

void main(string[] argv)
{
	ushort inputPort = cast(ushort)to!int(argv[0]);
	ushort port = argv.length == 1 ? inputPort : DumpsterSocket.getDefaultPort();
	auto socket = new DumpsterSocket(port);

}


