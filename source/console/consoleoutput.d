module console.consoleoutput;

import std.stdio;
import std.conv;

class ConsoleOutput{
    public:
        void write(string line){
            writeln(line);
        }
        void writeFormat(T)(string format, T[] args){
            writefln(format, args);
        }
}