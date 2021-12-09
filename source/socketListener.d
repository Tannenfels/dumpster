module socketListener;

import std.socket : InternetAddress, Socket, SocketException, SocketSet, TcpSocket;
import std.stdio : writefln;
import std.algorithm;
import console.socketlogger;

class DumpsterSocket
{
    private:
    static const ushort DEFAULT_PORT = 61888;
    ushort port = this.DEFAULT_PORT;
    TcpSocket listener;
    SocketLogger logger;

    public:
    this(ushort port = this.DEFAULT_PORT)
    {
        this.port= port;
        this.logger = new SocketLogger;
        this.start();
    }

    static ushort getDefaultPort()
    {
        return DumpsterSocket.DEFAULT_PORT;
    }

    int start(){
        listener = new TcpSocket();
        assert(listener.isAlive);
        listener.blocking = false;
        listener.bind(new InternetAddress(this.port));
        listener.listen(10);
        writefln("Listening on port %d.", this.port);

        enum MAX_CONNECTIONS = 60;
        auto socketSet = new SocketSet(MAX_CONNECTIONS + 1);
        Socket[] reads;
        while (true)
        {
            socketSet.add( listener);

            foreach (sock; reads)
                socketSet.add(sock);

            Socket.select(socketSet, null, null);

            for (size_t i = 0; i < reads.length; i++)
            {
                if (socketSet.isSet( reads[i]))
                {
                    char[1024] buf;
                    auto datLength = reads[i].receive( buf[]);

                    if (datLength == Socket.ERROR)
                        this.logger.write("Connection error.");
                    else if (datLength != 0)
                    {
                        writefln( "Received %d bytes from %s: \"%s\"", datLength, reads[i].remoteAddress().toString(), buf[0..datLength]);
                        this.logger.writeFormat!string("Received %d bytes from %s: \"%s\"", datLength, reads[i].remoteAddress().toString(), buf[0..datLength]);
                        continue ;
                    }
                    else
                    {
                        try
                        {
                            // if the connection closed due to an error, remoteAddress() could fail
                            writefln( "Connection from %s closed.", reads[i].remoteAddress().toString());
                        }
                        catch (SocketException)
                        {
                            this.logger.write("Connection closed.");
                            return 1;
                        }
                    }

                    // release socket resources now
                    reads[i].close();

                    remove(reads, i);
                    // i will be incremented by the for, we don't want it to be.
                    i--;

                    writefln( "\tTotal connections: %d", reads.length);
                }
            }

            if (socketSet.isSet( listener))        // connection request
            {
                Socket sn = null;
                scope (failure)
                {
                    writefln( "Error accepting");

                    if (sn)
                        sn.close();
                }
                sn = listener.accept();
                assert(sn.isAlive);
                assert(listener.isAlive);

                if (reads.length < MAX_CONNECTIONS)
                {
                    writefln( "Connection from %s established.", sn.remoteAddress().toString());
                    reads ~= sn;
                    writefln( "\tTotal connections: %d", reads.length);

                }
                else
                {
                    writefln( "Rejected connection from %s; too many connections.", sn.remoteAddress().toString());
                    sn.close();
                    assert(!sn.isAlive);
                    assert(listener.isAlive);
                }
            }

            socketSet.reset();

        }
    }
} 
