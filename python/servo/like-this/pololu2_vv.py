"""
The CKBot.pololu module provides classes used to communicate with other modules on a Pololu network (rather than CAN) using a protocol similar to the Robotics Bus Protocol. For more information on
the low-level interface, please refer to the Pololu Device User Manual found at www.pololu.com/file/0J38/ssc04a_guide.pdf our implementation assumes the Pololu Device is set to Pololu Mode,and not Mini SSC II Mode. 

These are primarily used to interface with the CKBot Cluster code found in the MODLab CKBot repository.

Classes in this module implement their own protocol that mimics the Robotics Bus protocol. It generates fake heartbeats and can send serial commands to the Pololu Controller

Main uses of this module:
(*) control modules connected to a Pololu device
(*) mimics the behaviour of the CAN Bus, except using the Pololu Device as a communications channel, can only
send position and go_slack commands currently

Example 1 - Pololu module only: 
nodes = {0:0x23, 5:0x65}
bus = pololu.Bus()
p = pololu.Protocol(bus = bus, nodes = nodes)
p.send_cmd(0x23,4,1000)  

Example 2 - Integrate with Cluster:
import ckbot.logical
nodes = {0:0x23, 5:0x65}
bus = pololu.Bus()
p = pololu.Protocol(bus = bus, nodes = nodes)
c = ckbot.logical.Cluster(p)
c.populate(2,{0x23:'head', 0x65:'tail'})
c.at.head.set_pos(1000)

Both examples send the 0x23 module, which is at Pololu port 0, a set position to 1000 command
"""

import time
import serial
import sys
import struct
import commands

#import logical2_vv

# Used for opening serial connection
mswindows = (sys.platform == "win32")
mac = (sys.platform == "darwin")

##V: What should the error messages be like?
class BusError( StandardError ):
  def __init__(self, err):
    StandardError.__init__(self,"Pololu Serial bus error: %s" % err)

class ProtocolError( StandardError ):
  def __init__(self, err):
    StandardError.__init__(self,"Pololu Protocol error: %s" % err)

#Belongs in pololu.py  -- mimics can.Bus()
class Bus(object):
  """
  Concrete class that provides the functionality
  needed to send messages to a pololu controller
  over a serial connection. 

  It is responsible for correctly formatting certain inputs
  to Pololu-understandable formats as documented in the Pololu
  User Manual located at www.pololu.com/file/0J38/ssc04a_guide.pdf
  """

  def __init__(self, baud=38400, timeout=0.1, port=None, usb_num=11, crc_enabled=False):
    """
    Initialize a Pololu Bus class

    INPUT:
    baud -- int -- the baud rate, between 1200-38400, for serial RS-232 connection
    timeout -- int -- timeout in seconds when attempting to connect to serial
    port -- int -- port number (USB) where Pololu device is connected(autodetected on linux)

    ATTRIBUTES:
    ser -- serial handle
    """
    self.ser = None
    self.port = None
    self.baud = baud
    self.timeout = timeout
    self.usb_num = usb_num
    self.crc_enabled = crc_enabled
    self.open()
    
  def get_errors(self):
    self.write((0xA1,0))
    
    while not self.ser.inWaiting():
      continue

    high = self.ser.read()
    while self.ser.inWaiting():
      low = high
      high = self.ser.read()
    
    return low | (high << 8)

  def open(self):
    """
    Open serial connection to the pololu controller,
    if none found, raises a BusError
    """
    
      # Don't open another serial port
    if self.ser is not None:
      return

       # This should auto-detect the OS and ports
    if mswindows:
      self.port = self.usb_num
    else: #linux
      self.usb_num = 0 #TODO not hardcode this way. prompt user??
      if mac:
        port_str = commands.getstatusoutput('ls /dev/tty.usb*')[1]
      else:
        port_str = commands.getstatusoutput('ls /dev/ttyUSB*')[1]
        
    self.port = port_str.split('\n')[self.usb_num]
    self.ser = serial.Serial(self.port,self.baud,timeout=self.timeout)

    print 'Using serial port: %s'%self.ser

  def write(self, val):
    """
    Write data to the pololu controller over serial
    
    INPUT:
    val -- tuple -- tuple of ints to write to serial
    """
    try:
      cmd_str = self.pololu_fmt(val)
      if self.crc_enabled:
        cmd_str = self.crc7(cmd_str) # Calculate and append Cyclic Redundancy Check byte
    except BusError, e:
      raise

    self.ser.write(cmd_str)            

  def close(self):
    """
    Close serial connection to the pololu controller if
    a connection has been made
    """
    self.ser.close()

  def pololu_fmt(self, val):
    """
    Correctly formats inputs to pololu strings to be sent over serial,
    this should work with all modes of protocols (MiniSSC2, Compact, and Pololu)
    
    INPUT:
    val -- tuple -- (cmd, servonum, data1, data2)
    
    OUTPUT:
    pololu_str -- string -- correctly formatted string as specified by the Pololu User Manual
    should resemble "x80x01x<cmd>x<servonum>x<data1>x<data2>"
    """
    num_args = len(val)
    pololu_str = ""
    
    # Formatting of integer values to chr
    # Essentially does struct.pack('BBBBB',val), with some type checking before hand
    for i in xrange(num_args):
      if not isinstance(val[i], int):
        raise BusError("Values must be 1 byte integers (between 0 and 255).")

      add_fmt_str = struct.pack("B",val[i])
      pololu_str = "".join( [pololu_str, add_fmt_str] ) 
      
    return pololu_str

    #self.bus.write( (MiniSSC2Protocol.START_BYTE, servonum, data) )
  
  def crc7(self,comstr):
    """
    This function calculates and appends the Cyclic Redundancy Check (CRC7) byte for error checking
    """
    l = len(comstr)   

    int_tuple = struct.unpack('B'*len(comstr), comstr)
    divd = self.__bitrev(int_tuple)

    if(l>4):
      print " This CRC function currently does not support strings > 4 chars"
      return 0
    
    divd = self.__bitrev(ord(comstr[0]))

        # put the chars in an integer 
    for i in range(1,l):
      new = self.__bitrev(ord(comstr[i]))
      divd <<= 8
      divd = divd | new

        #crc = 0b10001001<<(8*(l-1))
      crc = int('10001001',2)<<(8*(l-1)) #J binary literals don't work in python 2.5
      lsbcheck = 0x80 << (8*(l-1))
    
      for i in range(0,8*l):
        if(divd & lsbcheck == lsbcheck):
          divd = divd ^ crc
          divd = divd << 1
        else:
          divd = divd<<1

      divd = divd>>(8*(l-1))
      divd = self.__bitrev(divd)
      s = chr(divd & 0xff)

      return comstr + s

  def __bitrev(self,bytes):
    """
    Creates a lookup table of reversed bit orders

    Input: 
       bytes -- tuple -- tuple of 1 byte values to be reversed
    Output:
       bitrev_table -- dict
    """
    bytes = sum(bytes)         # Sums the bytes
    bin_repr = bin(bytes)[2:]  # Convert to binary string, remove "0b" at the beginning of the string
    bin_repr = bin_repr[::-1]  # Reverse all digits
    bin_repr = "0b%s" % bin_repr
    
    return int(bin_repr,2)     # Convert back to int, and return
      

class PololuProtocol(object):
  """
  This is a concrete class that provides all the 
  functionality needed to send messages to a pololu 
  controller over a "pololu bus". This protocol follows
  the specifications provided by the Pololu Maestro 
  Documentation found at:
  http://www.pololu.com/docs/0J40/all
  
  For use with the Pololu Maestro 12pin, Firmware Version1.1
  
  It is meant to mimic the can.Protocol class, except
  for the pololu device rather than a CAN network
  
  This converts CKBot Module-specific commands into
  Pololu equivalents, and maintains the state of the
  Pololu device and its handles to modules via fake heartbeats
  
  WARNING: Current version has only been tested with the 
  12-pin Pololu Maestro Firmwarev1.1 and does NOT support Pololu-styled 
  commands (supports only MiniSSC2 and Compact), support for Pololu-styled 
  commands will be included in a future release perhaps
  """
  
  # MiniSSCII Protocol Sync Value (must ALWAYS be 0xFF) specified by Pololu Documentation
  MINISSC2_BYTE = 0xFF
  
  # Compact Protocol Sync Value (must be 0x9F)
  COMPACT_BYTE = 0x8F
  
  # Pololu Protocol Sync Value (must be 0xAA)
  # This is also to initialize the Maestro to begin receiving commands using the PololuProtocol
  POLOLU_BYTE = 0xAA
    
  ##V: Need to put this in a proper location
  POS_SLACK = 9001
  SLACK_MESSAGE = 0

  def __init__(self, bus=None, nodes=None):
    """
    Initialize a pololu.Protocol
    
    INPUT:
    bus -- pololu.Bus -- Serial bus used to communicate with Pololu Device
    nodes -- dictionary -- key:module node_id, value:pololu controller number
      
    ATTRIBUTES:
    heartbeats -- dictionary -- key:nid, value:(timestamp)
    msgs -- dictionary -- a fake representation of a dictionary message, used so the pololu.Protocol can "dock" onto existing Cluster interfaces (provides the Module version)
    
    FUTURE:
    buses -- may be a list of buses (Protocol can communicate with multiple buses by changing servonums)
    """
    if bus is None:
      self.bus = Bus()
    else:
      self.bus = bus

    self.nodes = nodes
    self.heartbeats = {} # Gets populated by update
    self.msgs = {}

    self.pololu_setup() # Must be called before the Maestro can begin to respond to commands

  def pololu_setup(self):
    self.bus.write( (PololuProtocol.POLOLU_BYTE,) )
    
  def send_cmd(self, nid, target, device=None, cmd_type=None):
    """
    Sends command to the Pololu Maestro via the Bus. 
    
    INPUTS:
    nid -- int -- Node ID to send the command to
    target -- int -- position to send servo to (value between 9000 and 0)
    """

    channel = self.nodes[nid] # Extract channel from node ID to channel map

    if target is PololuProtocol.POS_SLACK:
      # If 9001 is sent, set servo off using Compact Protocol
      cmd = (PololuProtocol.COMPACT_BYTE, channel, PololuProtocol.SLACK_MESSAGE)
    else:
      # Default to MiniSSC II Protocol
      cmd = (PololuProtocol.MINISSC2_BYTE, channel, target)
      
    self.bus.write(cmd)
    
  def request(self, key, __dummy__):
    """
    Fakes requesting a object dictionary entry, constructs self.msgs accordingly
    so that Cluster.newModuleIX can correctly locate the module type (PolModule)
    
    INPUTS:
    key -- (nid, index, subindex_start)
    __dummy__ -- ignored input, used for "docking"
    """
    
    # Initializes self.msgs, which are simulated object dictionary messages. 
    # Since pololu modules can't actually retrieve this information, the Protocol,
    # will fake them. But the actual faking is handled in .update()
    
    # self.msgs[typecode] = list()
    self.msgs[key] = []
      
    return self.msgs[key]

  def update(self):
    """
    Updates the pololu.MiniSSC2Protocol state that mimics the behaviour of can.Protocol. It updates
    timestamps of heartbeats heard on the bus.
    """
    # sets the of value all the entries in the heartbeats dictionary to the current time
    # This allows Cluster to believe that all the modules connected through Pololu are alive
    timestamp = time.time()
    dummydata = 0 # dummy data
    
    for nid in self.nodes.iterkeys():
      self.heartbeats[nid] = (timestamp, dummydata)
    
    # Set self.msgs[typecode][0] to the typecode of the module (PolModule)
    # This allows Cluster to know what type of module this is
    for key in self.msgs.iterkeys():
      self.msgs[key].append( Msg(dummydata, "PolServoModule", timestamp) ) # from Types["PolServoModule"]

    # Returns 0 so that Cluster.newModuleIX doesn't get stuck
    # Since it checks for incomplete messages (which we don't have anyway)
    return 0

  def generatePNA(self, nid):
    """
    Generates a pololu.ProtocolNodeAdaptor, connecting a pololu protocol with 
    a specific node id and returns it
    """ 
    return ProtocolNodeAdaptor(self, nid)

class Msg(object):
    """ 
    A concrete class representing a FAKE completed response to a Robotics Bus 
    Dictionary Object request.

    ATTRIBUTES:
      payload -- partial dictionary object assembled from segments
      timestamp -- time when full dictionary object response is received
      incomplete_msg -- contains individual segments of the dictionary object 
        response
    """
    def __init__(self, incomplete_msg, payload, timestamp):
        self.payload = payload
        self.timestamp = timestamp
        self.incomplete_msg = incomplete_msg

#Belongs in pololu.py -- mimics can.ProtocolNodeAdaptor
class ProtocolNodeAdaptor(object):
  """
  Utilizes the protocol along with nid to create 
  an interface for a specific module
  """

  def __init__(self, protocol, nid):
    self.p = protocol
    self.nid = nid

  def send_cmd(self, target):
    """
    Sends a command to the Pololu device over serial via the
    pololu.Protocol.send_cmd()
    
    INPUT:
    cmd_type -- int -- command type specified by the Pololu User Manual 
    (see pololu.Protocol.send_cmd for more info.)
    
    data -- int -- the payload data to send to the module
    """
      
        # Essentially passes on the call to the protocol, includes the nid
    try:
      self.p.send_cmd(self.nid, target)
    except ProtocolError, e:
      raise

# Belongs in logical.py    
## Safety/range values goes in here
class PololuServoModule( object ):
  """
  PololoServoModule Class has the basic functionality of ServoModules, with some 
  exceptions listed below:
  
  - Pololu Modules cannot get_pos or is_slack
  - The Pololu Device allows for:
  - servo parameter settings
  - set speed
  - set neutral
  and various options for setting positions. We currently only use absolute 
  positions however. For more information refer to the Pololu User Manual
  on p.6
  """
  def __init__(self, node_id, typecode, pna, *argv, **kwarg):
    
    self.node_id = node_id
    self.typecode = typecode
    self.pna = pna

    self._attr=dict(
      go_slack="1R",
      set_pos="2W",
      get_pos="1R",
      is_slack="1R"
      )

    ##V: How should these be initialized? I just initialize them in set_pos / go_slack for now
    self.slack = None; # Initialized to True or False
    self.pos = None; # Initialized to start position of module

  @classmethod
  def _deg2pol(cls, angle, neutral=127):
    """
    Returns a correctly scaled module position
    
    INPUT:
    angle -- int -- between 9000 to -9000, in 100ths of degrees, 0 is neutral
    
    OUTPUT:
    corrected_angle -- int -- scaled between 0 and 255, 127 is neutral
    """
    m = 1.0*(255-0)/(9000--9000) # Constant scale factor
    corrected_angle = int(m*angle + neutral)
    return corrected_angle
  
  def is_slack(self):
    """
    Returns true if the module is slack, none if go_slack has not been called yet.
    
    WARNING: This function does NOT actually read states from the pololu device, returns an attribute that is updated by calls to set_pos and go_slack. If any external communications fail, then this function may report incorrect states 
    """
    return self.slack
  
  def get_pos(self):
    """
    Returns the 'believed' position of the module, none if set_pos has not been called yet.
    
    WARNING: This function does NOT actually read states from the pololu device, returns an attribute that is updated by calls to set_pos and go_slack. If any external communications fail, then this function may report incorrect states
    """
    return self.pos

  def go_slack(self):
    """
    Equivalent of setting a ServoModule slack. This is referred to as "off"
    as specified in the Pololu User Manual under the Command 0
    """            
    # Send the command via the PNA
    self.pna.send_cmd( PololuProtocol.POS_SLACK )

    # Module should now be slack
    self.slack = True

  def set_pos(self, pos):
    """
    Sets the position of a pololu module. 
    
    Uses the Pololu Set Absolute Position (Command 4)
    specified by the Pololu User Manual
    
    INPUT:
    pos -- int -- the desired position of the module, value between 9000 and -9000
    
    """ 
    # Ensures value is between 9000 and -9000 
    if pos > 9000 or pos < -9000:
      raise ValueError("Value out of bounds. Must be between 9000 and -9000.")

    corrected_pos = self._deg2pol(pos)

    # Send Position Command 
    self.pna.send_cmd(corrected_pos)
      
    # Module should now not be slack
    self.slack = False

    # Module should now be at this position
    self.pos = pos
