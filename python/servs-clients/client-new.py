# ------------------------------------------------------------------------------
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public
#  License as published by the Free Software Foundation; either
#  version 3.0 of the License, or (at your option) any later version.
#
#  The library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  General Public License for more details.
#
# (c)  Uriah Baalke
#
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
'''
A new client
   ... comments will be written when it works properly
'''
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

import select
import socket
import sys, os, time

# ---------------------------------------------------------------------------
# serialClient Class Definition
# ---------------------------------------------------------------------------

class serialClient(object):
    # ---------------------------------------------------------------------------
    # A server->socket->client: that connects to the serialServer and
    #                                   gives transparent access to the 
    #                                   Storque serial output stream while 
    #                                   also facilitating serial transmissions
    #                                   to the Storque
    # ---------------------------------------------------------------------------

    # ---------------------------------------------------------------------------
    # Initialize the serialClient(with port, and host) arguments:
    # 
    # notes: 
    #       - Remember to make sure that client and server ports are 
    #         the same
    #       - The host is the location of the server, on a single comp this is
    #         localhost
    # ---------------------------------------------------------------------------

    def __init__(self, port, host):
        print port
        self.port = int(port)
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.client.connect((host,self.port))
        self.pipe = self.client.makefile('wr', 0)
        print "Client Initialized on port: %s" %(port)
    
    # ---------------------------------------------------------------------------
    # runClient: this is currently purposeless and needs to be modified so that 
    #            it is actually useful for multiple applications or something
    #
    # ---------------------------------------------------------------------------
        
    def runClient(self):
        
        inputs = [self.client, sys.stdin, self.pipe]
        self.outputs = []
        Run = True
        
        while(Run):
            inputready, outputready, exceptready = select.select(inputs, self.outputs, [])
            
            for sel in inputready:
                
                if sel == sys.stdin:
                    userInput = sys.stdin.readline()
                    if userInput == "\n":
                        Run = False
                    else:
                        self.pipe.write(userInput)
                elif sel == self.pipe:
                    dataIn = sel.readline()
                    if dataIn:
                        print dataIn
                    else:
                        print "Server connection lost"
                        Run = False

        self.client.close()
# ---------------------------------------------------------------------------
# If 'run client-new.py' is called then instantiate and run serialClient
# ---------------------------------------------------------------------------
if __name__ == "__main__":
    serialClient(sys.argv[1], 'localhost').runClient()
