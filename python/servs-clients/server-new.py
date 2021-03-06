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
A new server:
   ... comments will be written when it works
'''
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

import select
import socket
import serial
import sys, os, time

# ------------------------------------------------------------------------------
# Server Class 
# ------------------------------------------------------------------------------

class serialServer(object):
    # ------------------------------------------------------------------------------
    # A serial->socket server: that allows multiple client processes
    #                          to use data from a single COM port
    # ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # Initialize serialServer(with port, and with backlog) arguments
    #   which define what port the server is on and how many clients
    #   it will accept.
    # ------------------------------------------------------------------------------
    
    def __init__(self, port, backlog, serialFile):
                                
        # Initialize Server
        self.clients = 0
     
        #Output list
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.inputs = []
        self.outputs = []

        # Find an open port and use it
        portFound = False
        while(not portFound):        
            try:
                self.server.bind(('',port))
                portFound = True
            except:
                print "Port %s currently in use" %(port)
                port = port + 1
                print "Trying port: %s " %(port)


        print "Server initialized on port: %s" %(port)
        self.server.listen(backlog)
        
    # ------------------------------------------------------------------------------
    # runServer: using select to multiplex inputs and outputs 
    #
    # ------------------------------------------------------------------------------
    
    def runServer(self):

        self.inputs = [self.server, sys.stdin]
        Run = True
        dataOut = ""
        junk = ""
        while(Run):
            try:
                inputready, outputready, exceptready = select.select(self.inputs, self.outputs, [])
            except select.error, e:
                break
            except socket.error, e:
                break
            
            for sel in inputready:
                
                if sel == self.server:
                    # Deal with server sockets
                    client, address = self.server.accept()
                    print "%s connected at %s" %(client.fileno(), address)
                    
                    self.clients += 1
                    pipe = client.makefile('wr',0)
                    self.inputs.append(pipe)
                    self.outputs.append(pipe)
                    
                elif sel == sys.stdin:
                    userInput = sys.stdin.readline()
                    if userInput == "\n":
                        print "Shutting down server"
                        Run = False
                    else:
                        for n in range(len(self.outputs)):
                          self.outputs[n].write(userInput)
                    
                else:
                    dataIn = sel.readline()
                    if dataIn:
                        print dataIn
                    else:
                        print "Client %s connection lost" %(sel.fileno())
                        self.clients -= 1
                        sel.close()
                        self.inputs.remove(sel)
                        self.outputs.remove(sel)
            
        self.server.close()

# ------------------------------------------------------------------------------
# If 'run serial-server-new.py' is called then instantiate and run serialServer
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    serialServer(4549, 5, '').runServer()
