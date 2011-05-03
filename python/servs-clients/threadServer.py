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
# A new Server using python's threading modules
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Imports
# ------------------------------------------------------------------------------

import sys, os, time
import select
import socket
import threading

# ------------------------------------------------------------------------------
# Threading Server Class
# ------------------------------------------------------------------------------

class threadServer(object):
  
  def __init__(self, port, backlog):
    self.Run = True
    #Initialize Clients
    self.clients = 0
    self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    self.inputs = []
    self.outputs = []
    self.threads = []
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

  def runServer(self):
    self.inputs = [self.server, sys.stdin]
    dataOut = ""
    
    while(self.Run):
      try:
        inputready, outputready, exceptready = select.select(self.inputs, self.outputs, [])
      except select.error, e:
        break
      except socket.error, e:
        break

      for sel in inputready:

        if sel == self.server:
          #Handle Server Socket
          client, address = self.server.accept()
          print "%s connected at %s" %(client.fileno(), address)
          c = threadClient((client, address))
          c.start()
          self.threads.append(c)
   
        elif sel == sys.stdin:  # <--- note: need to pass these values to threads!!!!
          #Handle Standard Input
          userInput = sys.stdin.readline()
          if userInput == "\n":
            self.Run = False

# ------------------------------------------------------------------------------
# A Client Thread to handle client stuff
# ------------------------------------------------------------------------------          

class threadClient(threading.Thread):

  def __init__(self, (client, address)):
    threading.Thread.__init__(self)
    self.Run = True
    self.client = client
    self.address = address
    self.pipe = self.client.makefile('wr', 0)
    self.inputs = []
    self.outputs = []
    print "%s thread connected at %s" %(self.client.fileno(), self.address)
    
  def run(self):
    self.inputs = [sys.stdin, self.pipe]
    while(self.Run):
      try:
        inputready, outputready, exceptready = select.select(self.inputs, self.outputs, [])
      except select.error, e:
        break
      except socket.error, e:
        break
      
      for sel in inputready:

        if sel == sys.stdin:
          userInput = sys.stdin.readline()
          if userInput:
            self.pipe.write(userInput)
        
        if sel == self.pipe:
          pipeInput = self.pipe.readline()
          if pipeInput:
            print pipeInput
          else:
            print "%s thread disconnected at %s" %(self.client.fileno(), self.address)
            self.pipe.close()
            self.client.close()
            self.Run = False
            
    return
# ------------------------------------------------------------------------------
# Run threadServer
# ------------------------------------------------------------------------------
if __name__ == "__main__":
  threadServer(4549, 4).runServer()
