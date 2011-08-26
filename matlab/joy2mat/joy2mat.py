#!/bin/env python

"""
Joystic device to matlab via custom format as defined in _parse

The purpose of this is so that joy2mat.m can 
and provide a joystic interface for the user

- Uriah Baalke
"""

from sys import argv
from pygame import display, joystick, event
from struct import pack, unpack
from socket import socket, AF_INET, SOCK_DGRAM
from time import time as now, sleep

class joy2mat( object ):

    def __init__( self, port=65001, rate=10 ):
        """
        Initialize pygame based joystick interface
        
        INPUTS: 
          port -- int -- udp port for communication
          mode -- string -- either 0 which pushes events out
                                or 1 which polls at a given rate
          rate -- float -- polling frequency 
        """
	self.DEBUG = []	

        self.port = port
        self.rate = rate
    
        # Initialize socket
        self.sock = socket(AF_INET, SOCK_DGRAM)
        
        display.init()
        # Initialize joystick object
        joystick.init()
        num_joys = joystick.get_count()
        if num_joys < 1:
            print "No joysticks detected"
            exit
        self.j = joystick.Joystick(0)
        self.j.init()
        self.t0 = now()
        # Here we could do something cool where we send the parameters
        # of the joystick to but that is for later

    def _parse( self, evt ):
        """
        Parse an event and convert into custom 6 Byte format:
           1st Byte: {1: axis, 2: ball, 3: button, 4: hat}
           2nd Byte: number representing which axis/ball/button/hat 
           3-6th Bytes: 4 bytes describing a 'single'
        """
        evt = str(evt)
        evt = eval(evt[evt.rfind('{'):evt.rfind('}')+1])
        val = ''
        for t,v in evt.iteritems():
            if t is 'axis':
                descr = '\x01'+pack('B', v)
            elif t is 'ball':
                descr = '\x02'+pack('B', v)
            elif t is 'button':
                descr = '\x03'+pack('B', v)
            elif t is 'hat':
                descr = '\x04'+pack('B', v)
            elif t is 'value':
                val = pack('f', v)
            elif t is 'joy':
                continue
            # Remove other pygame events
            elif t is 'scancode': # If a keyboard event
                return ''
            elif t is 'buttons': # If a mouse event 
                return ''
            else:
                TypeError('Unknown description')            
        if val is '':
            val = pack('f', 0)
        return descr+val

    def push( self ):
        evts = event.get()
        # Push out all events found 
        for evt in evts:
            print evt            
            self.sock.sendto(self._parse(evt), ('', self.port))
        return len(evts)

    def pushevery( self, period ):
        if now()-self.t0 > period:
            self.push()
            self.t0 = now()
        return
            

if __name__ == "__main__":
    j = joy2mat()
    while True:
        j.pushevery(0.1)
    
    
