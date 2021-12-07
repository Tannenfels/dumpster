module dumpster.app;

import std.stdio;
import socketListener;

void main(string[] argv)
{
	ushort port = argv.length == 1 ? cast(ushort)argv[0] : DumpsterSocket.getDefaultPort();
	auto socket = new DumpsterSocket();


}


