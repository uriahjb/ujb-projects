#-------------------------------------------------------------------------
# New Server Test
#----------------------------------------------------------------------
'''
import sys, os, time
import math

def main():
  while(1):
    if (sys.stdin):
      input = sys.stdin.readline()
      print input

main()
'''


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

class ServerNew(object):
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
        self.backlog = 5
    
        #Output list
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.outputs = []
        self.pipes = []
        self.inputs = [self.server, sys.stdin]

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
        self.server.listen(self.backlog)
        
    # ------------------------------------------------------------------------------
    # runServer: using select to multiplex inputs and outputs 
    #
    # ------------------------------------------------------------------------------
    
    def runServer(self):

        Run = True
        while(Run):
          print self.server
          if (self.server):
            print 'server'
            #Deal with server sockets
            client, address = self.server.accept()
            print "%s connected at %s" %(client.fileno(), address)          
            self.clients += 1
            pipe = client.makefile('wr',0)
            self.pipes.append(pipe)
                                 
          for n in range(len(self.pipes)):
            print len(self.pipes)
            print self.pipes[n]
            for line in self.pipes[n]:
              pipeInput = line
              print 'pipe readline'
              if pipeInput:
                print pipeInput
              else:
                print "Client %s connection lost" %(self.pipes[n].fileno())
                self.clients -= 1
                self.pipes[n].close()
                self.pipes.remove(self.pipes[n])
          
          for line in sys.stdin:
            userInput = line
            print 'userinput'
            if userInput == "\n":
              print "Shutting down server"
              Run = False
            else:
              for n in range(len(self.outputs)):
                self.outputs[n].write(userInput)
            
        self.server.close()

# ------------------------------------------------------------------------------
# If 'run serial-server-new.py' is called then instantiate and run serialServer
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    ServerNew(4549, 5, '').runServer()

