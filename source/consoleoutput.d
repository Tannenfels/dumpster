module consoleoutput;

import std.stdio;

template Input(alias a)
{ 
     
} 


class ConsoleOutput{
    public:
        void write(string line){
            writeln(line);
        }
        void writeFormat(string format, A...)(in format[], A args){

        }
}