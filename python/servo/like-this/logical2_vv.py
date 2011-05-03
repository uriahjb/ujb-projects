import re
import can
from time import sleep, time as now
from warnings import warn
from traceback import extract_stack
import P18F2680

import pololu2_vv

"""
  The CKBots.logical module provides classes to create representations of 
  modules inside a cluster.

  Main uses of this module:
  (*) query the object dictionary of a module by its logical name
  (*) send a position command using a process message

  The top level of this module is cluster. Typically users will create a 
  cluster  to represent a set of modules that can communicate on the same 
  CANBus. Modules can be  addressed through logical names via the Attributes 
  class. 
"""

__all__ = [
    'ModulesByName','DiscoveryError','Cluster',
    'Module','ServoModule','GenericModule',
    'V1_3Module','V1_4Module'
]

def progress( msg ):
  pass

def nids2str( nids ):
  return ",".join(["Nx%02x" % nid for nid in nids])

def crop( val, lower, upper ):
  return max(min(val,upper),lower)
  
class ModulesByName(object):
  """
  Concrete class with a cluster's attributes.

  The cluster dynamically adds named attributes to instances of this class to 
  provide convenient names for modules
  """ 
  def __init__(self):
    self.__names = set()
  
  def _add( self, name, value ):
    setattr( self, name, value )
    self.__names.add(name)
    
  def _remove( self, name ):
    delattr( self, name )
    self.__names.remove(name)

  def __iter__(self):
    plan = list(self.__names)
    plan.sort()
    return iter(plan)

class DiscoveryError( StandardError ):
  """
  Exception class for CAN bus discovery failures
  """
  def __init__(self,msg,**kw):
    """
    ATTRIBUTES:
        timeout -- number -- seconds to timeout
        required -- set -- required node ID-s
        found -- set -- node ID-s found
        count -- number -- node count required
    """
    self.timeout = kw.get('timeout',0)
    self.count = kw.get('count',0)
    self.required = kw.get('required',set([]))
    self.found = kw.get('found',set([]))
    self.message = msg

class DelayedPermissionError( can.PermissionError ):
  """
  Callable object returned when setters or getters with
  are obtained for cluster properties that cannot be (resp.)
  written or read.
  
  A DelayedPermissionError stores the stack at its initialization
  to make it easier for the subsequent error to be traced back to 
  its original source.
  
  If called, a DelayedPermissionError raises itself.
  """
  def __init__(self, *arg, **kw):
    can.PermissionError.__init__(self,*arg,**kw)
    self.init_stack = extract_stack()
  
  def __call__( self, *arg, **kw ):
    raise self
    
class Cluster(dict):
  """
  Concrete class representing a CKBot cluster.

  A Cluster instance is a dictionary of modules. A Cluster also contains a 
  Protocol class to communicate on the CANBus of the cluster, and the
  convenience attribute at, which provides syntactic sugar for naming modules

  Typical use:
    >>> c = Cluster()
    >>> c.populate(3,{ 0x91 : 'left', 0xb2 : 'head',0x5d : 'right'} )
    >>> for m in c.itervalues():
    >>>   m.get_od(c.p)
    >>> c.at.head.od.set_pos( 3000 ) # via object dictionary
    >>> c.at.head.set_pos(4500) # via process message
  """
  def __init__(self,protocol=None,*args,**kwargs):
    """
    Concrete constructor.
      bus -- Bus class or bus instance to use; default is can.Bus 
      
    ATTRIBUTES:
      p -- instance of Protocol for Robotics Bus communication
      at -- instance of the Attributes class.
      limit -- float -- heartbeat time limit before considering node dead
    """
    dict.__init__(self,*args,**kwargs)
    if protocol is None:
      self.p = can.Protocol()
    elif type(protocol)==type:
      self.p = protocol()
    else:
      self.p = protocol
    self.at = ModulesByName()
    self.limit = 2.0

  def populate(self, count = None, names = {}, timeout=2, timestep=0.1,
                required = set(), fillMissing=None, walk=False,
                autonamer=lambda nid : "Nx%02X" % nid ):
    """
    Tries to populate the cluster based on heartbeats observed on the bus.
    Will terminate when either at least count modules were found or timeout
    seconds have elapsed. While waiting, checks bus once every timestep seconds.
    If timed out, raises an IOError exception.

    If the bus already got all the heartbeats needed, populate() should 
    terminate without sleeping.
	
    If provided, names gives a dictionary of module names based on their node 
    ID.	Node IDs that aren't found in the dictionary have a name automatically
    generated from the ID by calling autonamer.

    INPUT:
      count, timeout, timestep, required, fillMissing-- see self.discover()
      fillMissing -- class / bool -- fills in any missing yet required modules
            with instances of this class. If boolean true, uses MissingModule
      names -- dictionary of Modules names based with node id as their key.
      walk -- bool -- if true, walks each module to indentify its interface
      autonamer -- names the modules if no names are given.
    """
    self.clear()
    if fillMissing is None:
      exc = DiscoveryError
    else:
      exc = None
    required = set(required)
    nids = self.discover(count,timeout,timestep,required,raiseClass = exc)
    for nid in nids:
      name = names.get(nid, autonamer(nid))
      mod = self.newModuleIX( nid, name )
      self.add(mod)
      if walk:
        mod.get_od()
    if fillMissing:      
      if type(fillMissing) is not type:
        fillMissing = MissingModule
      for nid in required - nids:
        name = names.get(nid, autonamer(nid))
        mod = fillMissing( nid, name )
        self.add(mod)           
          
  def discover( self, count = 0, timeout=2, timestep=0.1, required=set(), raiseClass=DiscoveryError ):
    """
    Discover which nodes are in the cluster.
    Termination condition for discovery is that at least count modules were
    discovered, and that all of the required modules were found.
    If this hasn't happened after a duration of timeout seconds (+/- a timestep),
    discover raises a DiscoveryError.
    In the special case of count==0 and required=set(), discover collects
    all node ID-s found until timeout, and does not return an error.
    INPUT:
      count -- number of modules -- if 0 then collects until timeout
      timeout -- time to listen in seconds
      timestep -- how often to read the CAN buffer
      required -- set -- requires that all these nids are found
      raiseClass -- class -- exception class to raise on timeout
    OUTPUT:
      python set of node ID numbers    
    """
    required = set(required)
    # If any number of nodes is acceptable --> wait and collect them
    if not count and not required:
      progress("Discover: waiting for %g seconds..." % timeout)
      sleep(timeout)
      nids = self.getLive(timeout)
      progress("Discover: done. Found %s" % nids2str(nids))
      return nids 
    # else --> collect nodes with count limit, timeout, required
    time_end = now()+timeout
    nids = self.getLive(timeout)
    while (len(nids) < count) or not (nids >= required):
      sleep(timestep)
      nids = self.getLive(timeout)
      progress("Discover: found %s" % nids2str(nids))
      if time_end < now():
        if raiseClass is None:
          break
        raise raiseClass("CAN discovery timeout",
          timeout=timeout, found=nids, required=required, count=count )
    return nids

  def off( self ):
    """Make all servo or motor modules currently live go slack"""
    for nid in self.getLive():
      m = self[nid]
      if isinstance(m,ServoModule):
        self[nid].go_slack()
      if isinstance(m,MotorModule):
        self[nid].go_slack()

  def who( self, t = 10 ):
    """
    Show which modules are currently visible on the bus
    runs for t seconds
    """
    t0 = now()
    while now()-t0<t:
      lst = []
      for nid in self.getLive():
        if self.has_key(nid):
          lst.append( '%02X:%s' % (nid,self[nid].name) )
        else:
          lst.append( '%02X:<?>' % nid )
      print "%.2g:" % (now()-t0),", ".join(lst)
      sleep(1)

  def add( self, *modules ):
    """
    Add the specified modules (as returned from .newModuleIX()) 
    """
    for mod in modules:
      progress("Adding %s %s" % (mod.__class__.__name__,mod.name) )

      ##V: How to properly do this?
      assert isinstance(mod,Module) or isinstance(mod, pololu2_vv.PololuServoModule)
      self.at._add(mod.name, mod)
      self[mod.node_id] = mod
    return self
    
  def newModuleIX(self,nid,name=None):
    """
    Build the interface for a module
    INPUTS
        nid -- int -- node identifier for use on the bus
        name -- string -- name for the module, or None if regenerating
            an existing module whose name is already known
    OUTPUTS
        mod -- Module subclass representing this node
    """
    nid = int(nid)
    if name is None:
      name = self[nid].name
    typecode_key = (nid, 0x1000, 0xF7)
    self.p.request(typecode_key, -1)
    while self.p.update() > 0:
      pass
    pld = self.p.msgs[typecode_key][0].payload 
    if pld and isinstance( pld[0], Exception ): 
      raise pld[0]
    assert(isinstance(pld, str))
    typecode = pld.replace('\x00','')
    #pna = can.ProtocolNodeAdaptor( self.p, nid )
    #mod = Module.newFromCAN(nid, typecode, pna )
    pna = self.p.generatePNA(nid)
    mod = Module.newFromDiscovery(nid, typecode, pna)
    mod.name = name
    return mod

  def __delitem__( self, nid ):
    self.at._remove( self[nid].name )
    dict.__delitem__(self,nid)

  def itermodules( self ):
    for mnm in self.at:
      yield getattr(self.at,mnm)

  def iterhwaddr( self ):
    nids = self.keys()
    nids.sort()
    for nid in nids:
      for index in self[nid].iterhwaddr():
        yield Cluster.build_hwaddr( nid, index )
  
  def iterprop( self, attr=False, perm='' ):
    for mod in self.itermodules():
      if attr:
        for prop in mod.iterattr(perm):
          yield mod.name + "/@" + prop
      for prop in mod.iterprop(perm):
        yield mod.name + "/" + prop

  def getLive( self, limit=None ):
    """
    Use heartbeats to get set of live node ID-s
    INPUT:
      limit -- float -- heartbeats older than limit seconds in 
         the past are ignored
    OUTPUT:
      python set of node ID numbers
    """
    if limit is None:
      limit = self.limit
    t0 = now()
    self.p.update()
    return set( ( nid 
      for nid,(ts,_) in self.p.heartbeats.iteritems()
      if ts + limit > t0 ) )

  @staticmethod
  def build_hwaddr( nid, index ):
    "build a hardware address for a property from node and index"
    return "%02x:%04x" % (nid,index)
  
  REX_HW = re.compile("([a-fA-F0-9]{2})(:)([a-fA-F0-9]{4})")
  REX_PROP = re.compile("([a-zA-Z_]\w*)(/)((?:[a-zA-Z_]\w*)|(?:0x[a-fA-F0-9]{4}))")
  REX_ATTR = re.compile("([a-zA-Z_]\w*)(/@)([a-zA-Z_]\w*)")
    
  @classmethod
  def parseClp( cls, clp ):
    """
    parse a class property name into head and tail parts
    
    use this method to validate class property name syntax.
    
    OUTPUT: kind, head, tail
        where kind is one of ":", "/", "/@"        
    """
    m = cls.REX_HW.match(clp)
    if not m: m = cls.REX_PROP.match(clp)
    if not m: m = cls.REX_ATTR.match(clp)
    if not m:
      raise ValueError("'%s' is not a valid cluster property name" % clp )
    return m.group(2),m.group(1),m.group(3)
        
  def modOfClp(self, clp ):
    """
    Find the module containing a given property
    """
    kind,head,tail = self.parseClp(clp)
    # Hardware names
    if kind==":":
      return self[int(head,16)]
    # Property or Attribute
    if kind[:1]=="/":
      return getattr( self.at, head )
    
  def _getAttrOfClp( self, clp, attr ):
    """(private)
    Obtain python attribute of a cluster property identified by a clp
    """
    kind,head,tail = self.parseClp(clp)
    # Hardware names
    if kind==":":
      nid = int(head,16)
      index = int(tail,16)
      try:
        od = self[nid].od
      except KeyError:
        raise KeyError("Unknown node ID 0x%02x" % nid)
      if od is None:
        raise ValueError("Node %s (ID 0x%02x) was not scanned for properties. Use get_od() or populate(...,walk=1) " % (self[nid].name,nid))
      try:
        return getattr(od.index_table[index],attr)
      except KeyError:
        raise KeyError("Unknown Object Dictionary index 0x%04x" % index)
        
    # Property or Attribute
    if kind[:1]=="/":
      mod = getattr( self.at, head )
      return mod._getModAttrOfClp( kind+tail, attr )
    
  def getterOf( self, clp ):
    """
    Obtain a getter function for a cluster property
    
    If property is not readable, returns a DelayedPermissionError
    """
    if self._getAttrOfClp(clp,'isReadable')():
      return self._getAttrOfClp(clp,'get_sync')
    return DelayedPermissionError("Property '%s' is not readable" % clp)
  
  def setterOf( self, clp ):
    """
    Obtain a setter function for a cluster property
    
    If property is not writeable, returns a DelayedPermissionError
    """
    if self._getAttrOfClp(clp,'isWritable')():
      return self._getAttrOfClp(clp,'set')
    return DelayedPermissionError("Property '%s' is not writable" % clp)

class AttributeGetter( object ):
  """
  Callable wrapper for providing access to object properties via
  a getter function
  
  AttributeGetter(obj,attr)() is getattr(obj,attr) 
  """
  def __init__(self,obj,attr):
    self.obj = obj
    self.attr = attr
  
  def __repr__( self ):
    return "<%s at 0x%x for %s of %s>" % (
      self.__class__.__name__, id(self), self.attr, repr(self.obj) )
    
  def __call__(self):
    return getattr(self.obj,self.attr)


class AttributeSetter( object ):
  """
  Callable wrapper for providing access to object properties via
  a setter function
  
  AttributeSetter(obj,attr)(value) is setattr(obj,attr,value) 
  """
  def __init__(self,obj,attr):
    self.obj = obj
    self.attr = attr
  
  def __repr__( self ):
    return "<%s at 0x%x for %s of %s>" % (
      self.__class__.__name__, id(self), self.attr, repr(self.obj) )
    
  def __call__(self,value):
    setattr(self.obj,self.attr,value)

class Module(object):
  """
  Abstract superclass representing a CKBot module.
  Cluster creates the appropriate Module subclass by calling 

    >>> p = can.Protocol(can.Bus())
    >>> p.bus.open()
    >>> node_id = 0x01 #e.g. module with node id 0x01
    >>> node_type = "CKBotV1_2"
    >>> m = Module,newFromCAN(node_id, node_type) 
    >>> m.get_od(p)
  """
  # dictionary mapping module type-codes (as read from CAN via object 
  # dictionary to the appropriate Module subclass
  #J is this how we document class attributes?
  Types = {}

  @classmethod
  def newFromCAN(cls, nid, typecode, pna ):
    """
    Factory method for instantiating Module subclasses given a node id and typecode
    pna is the protocol node adaptor for this nid    
    """
    subclass = cls.Types.get(typecode,GenericModule)
    m = subclass(nid, typecode, pna )
    m.code_version = typecode
    return m
    
  @classmethod
  def newFromDiscovery(cls, nid, typecode, pna):
    """
    Factory method for instantiating Module subclasses given a node id and typecode
    pna is the protocol node adaptor for this nid

    NOTE: This will replace newFromCAN
    """
    subclass = cls.Types.get(typecode,GenericModule)
    m = subclass(nid, typecode, pna)
    m.code_version = typecode
    return m

  def __init__(self, node_id, typecode, pna ):
    """
    Concrete constructor. 

    ATTRIBUTES:
      node_id -- 7 bit number to address a module uniquely
      typecode -- version number of module code #TODO provide url for 
      more info
      pna -- ProtocolNodeAdaptor -- specialized for this node_id
    """
    self.node_id = int(node_id)
    self.od = None
    self.code_version = None  

    ##V Need to fix this?
    assert pna is None or isinstance(pna,can.ProtocolNodeAdaptor)
    assert pna is None or pna.nid == node_id 
    self.pna = pna
    self.name = None
    self._attr = {}
    #these lines added from mem classes
    self.mcu = None
    self.mem = None
  
  def get_od(self):
    """
    This method creates an Object dictionary for this module. 
    """
    if self.od is None:
        self.od = self.pna.get_od(progress=progress)

  def iterhwaddr(self):
    """
    Iterator for all Object Dictionary index addresses in this module
    
    The addresses are returned as integers 
    """
    if self.od is None:
      return iter([])
    return self.od.index_table.iterkeys()
 
  def iterprop(self, perm=''):
    """
    Iterator for Object Dictionary properties exposed by this module
    
    INPUTS:
      perm -- string -- ''(default) all properties; 'R' readable/gettable
                'W' writable/settable
    OUTPUT:
      property names returned as strings
    """
    if self.od is None or perm not in 'RW':
      return iter([])
    idx = self.od.name_table.iterkeys()
    if perm=='R':
      return (nm for nm in idx if self.od.name_table[nm].isReadable())
    elif perm=='W':
      return (nm for nm in idx if self.od.name_table[nm].isWritable())    
    return idx
  
  def iterattr(self,perm=''):
    """
    Iterator for module attributes exposed by this module class
    
    INPUTS:
      perm -- string -- ''(default) all properties; 'R' readable/gettable
                'W' writable/settable
    OUTPUT:
      property names returned as strings
    """
    plan = self._attr.iteritems()
    if perm:
      return (nm for nm,acc in plan if perm in acc)
    return (nm for nm,_ in plan)
  
  def _getAttrProperty( self, prop, req ):
    """(private)
    Access python attributes exposed as properties 
    ('/@' property names)
    """
    def boolambda( b ):
      if b:
        return lambda : True
      return lambda : False
    # Check what access is provided to this attribute
    perm = self._attr.get(prop,None)
    if perm is None:
      raise KeyError("Property '@%s' was not found in class %s" 
                     % (prop,self.__class__.__name__) )        
    # Try to access attribute; generates error on failure
    val = getattr( self, prop )
    ## Attribute permissions:
    #   R -- readable; by default using AttributeGetter
    #   W -- writeable; by default using AttributeSetter
    #   1 -- method with no parameters, treated as a getter
    #   2 -- method with 1 parameter, treated as a setter
    if req == 'isReadable': return boolambda( "R" in perm )
    elif req == 'isWritable': return boolambda( "W" in perm )
    elif req == 'get_sync':
      if "1" in perm: return val
      if "R" in perm: return AttributeGetter(self,prop)
    elif req == 'set':
      if "2" in perm: return val
      if "W" in perm: return AttributeSetter(self,prop)
    raise TypeError("Property '@%s' does not provide '%s'" % (prop,req)) 
    
  def _getModAttrOfClp( self, clp, attr ):
    """
    Obtain a module attribute from a clp
    
    At the module level, the clp is expected to start with '/'
    
    This is the Module superclass implementation.
    clp-s starting with /@ expose module attrbiutes
    """
    assert clp[0]=="/", "Logical clp-s only"
    if clp[:2]=="/@":
      return self._getAttrProperty(clp[2:],attr) 
    # Must be an OD property access
    if self.od is None:
      raise KeyError('ObjectDictionary was not initialized; use .get_od() or populate(...,walk=1)')
    # Look for OD name
    odo = self.od.name_table[clp[1:]]
    return getattr( odo, attr )

  def start(self):
    """
    This method sends a CAN Message to start this module.
    """
    self.pna.start()

  def stop(self):
    """
    This method sends a CAN Message to stop this module.
    """
    self.pna.stop()

  def reset(self):
    """
    This method sends a CAN Message to reset this module.
    """
    self.pna.reset()

class MemInterface( object ):
  """
  Implementation of the .mem sub-object for modules that provide the generic IO memory interface
  
  Instances of this class are created by the module subclass constructor, for those module software
  versions that actually implement the interface.

  Typical usage, assuming m is a module:
  >>> m.mem[0xBAD] = 0xC0ED
  >>> print m.mem[0xDEAD]
  >>> m.mem[[0xBAD, 0xD00D]] = [0xBE, 0xEF]
  >>> print m.mem[[0xC0ED, 0xBABE]]
  >>> m.mem[0xF00] |= (1<<5) # set bit 5
  >>> m.mem[0xF00] &= ~(1<<5) # clear bit 5
  >>> m.mem[0xF00] ^= (1<<5) # toggle bit 5
  
  If the module also has a .mcu sub-object, it will typically provide the constants needed instead of
  the literals in the example above.
  """
  def __init__(self, module):
    "Attach memory sub-object to this module"
    self.set = module.mem_write
    self.get = module.mem_read

  def __getitem__( self, key ):
    """
    Read memory from microcontroller.
    
    key can either be an integer memory address, or a list of such addresses.
    When a list is used, returns a list of the results
    """
    if type(key) is list:
      return [ self.get(k) for k in key ]
    #elif type(key) is tuple:
    #  addr, bit = key
    #  return (self.get(addr) & (1<<bit)) != 0
    return self.get(key)

  def __setitem__(self, key, val):
    """
    Write memory values in microcontroller
    
    key can be an address and val a byte value, or key is a list of addresses, and val a sequence of
    values (i.e. val can also be a tuple, or any other sequence type).
    """
    if type(key) is list:
      for k,v in zip(key,val):
        self[k]=v
    #elif type(key) is tuple:
    #  addr, b = key
    #  tmp = self.get(addr)
    #  if val:
    #    self.set( addr, tmp | (1<<b))
    #  else:
    #    self.set( addr, tmp & ~(1<<b))
    else:
      self.set(key,val)

class MemAt0x1010( object ):
  GIO_R_ADDR = 0x1011
  GIO_R_VAL = 0x1012
  GIO_W_ADDR = 0x1021
  GIO_W_VAL = 0x1022

class MemAt0x1000( object ):
  GIO_W_ADDR = 0x1001
  GIO_R_VAL = 0x1004
  GIO_R_ADDR = 0x1003
  GIO_W_VAL = 0x1002

class MemIxMixin( object ):
  """
  Module mixin class implementing memory interface

  This adds mem_read and mem_write methods, and a get_mem 
  """
       
  def mem_write( self, addr, val ):
     "Write a byte to a memory address in the module's microcontroller"
     self.pna.set( self.GIO_W_VAL, "B", val )
     self.pna.set( self.GIO_W_ADDR, "H", addr )

  def mem_read( self, addr ):
     "Read a memory address from the module's microncontroller"
     self.pna.set( self.GIO_R_ADDR, "H", addr )
     return self.pna.get_sync( self.GIO_R_VAL, "B" )
     
  def mem_getterOf( self, addr ):
     "Return a getter function for a memory address"
     # Create the closure
     def getter():
       return self.mem_read(addr)
     return getter
     
  def mem_setterOf( self, addr ):
     "Return a setter function for a memory address"
     # Create the closure
     def setter(val):
       return self.mem_write(addr,val)
     return setter
    
class SensorModule( Module ):
  """Abstract superclass for all sensor module classes
  
  Implements the .pins member, used to coordinate between ports regarding 
  pin usage.
  
  """
  def __init__(self, nid, typecode, pna):
      Module.__init__(self, nid, typecode, pna)
      self.pins = {}

class MCU_Port( object ):
  """Abstract superclass representing all MCU ports -- used or unused
  """
  def __init__(self,pins,**kw):
    """
    INPUTS:
      keyword parameters are assigned as attributes
    """
    for k,v in kw.iteritems():
      if hasattr(self,k):
        raise AttributeError("Attribute '%s' already exists" % k)
      setattr(self,k,v)
    self.need_pins = set(pins)
    self.active = False
  
  def use(self, pinass, pins=None):
    """
    INPUT:
      pinass -- dict -- table of pin assignments mapping pins to the port 
        object owning them
      pins -- set or None -- set of pins to actually take over; uses port 
        defaults if not specified
    OUTPUT:
      updates the value of pinass to reflect newly used pins
    """
    if pins is None:
      pins = self.need_pins
    used = set(pinass.keys())
    if not used.isdisjoint(pins):
      raise IndexError("Needed pins %s are not free" 
        % (used.intersection(pins) ) )
    for p in pins:
      pinass[p] = self
    self.active = True
    
class Pic18GPIO( MCU_Port ):
  """Concrete class representing a GPIO port on a PIC18 MCU
  
  Usage: assume m.gpio_A is a Pic18GPIO instance, and m has .mcu, .mem, .pins
  >>> m.gpio_A.use( m.pins )
  >>> m.gpio_A.set_inputs( 0xF0 )
  >>> m.gpio_A.put( 3 )
  >>> print m.gpio_A.get()
  """
  def __init__(self,pins,**kw):
    """
    INPUTS:
      keyword parameters are assigned as attributes
    """
    MCU_Port.__init__(self,pins,**kw)
    self.imask = "<<GENERATE ERROR FOR UNINITIALIZED MASK>>"

  def set_inputs( self, mask ):
    """
    INPUT:
      mask -- byte -- bit-mask of bits to be used as inputs
    """
    assert self.active,"Must call use() to activate this port first"
    mask = int(mask)
    if mask<0 or mask>255:
      raise ValueError("Mask 0x%x out of range -- must be a byte" % mask)
    self.imask = mask
    self._set_tris(mask)
        
  def get(self):
    """
    Reads GPIO pins and returns the value.
    
    The value of non-input pins is undefined
    """
    assert self.active,"Must call use() to activate this port first"
    return self._get_port()

  def put(self,val):
    """
    Writes a byte to a GPIO port.
    
    Only bits that were declared as non-inputs may be used.
    """
    assert self.active,"Must call use() to activate this port first"
    return self._set_latch(val & ~self.imask)
  
  def setterForMask(self,mask):
    """
    Returns a setter function that writes only specified bits
    """
    def setter(val):
      try:
        val = (val & mask) | (self._get_port() & ~mask)
        self._set_latch(val & ~self.imask)
      except TypeError,err:
        raise TypeError("%s : did you forget to call set_input()?" % str(err))
    return setter
    
class Sensor_v16( SensorModule, MemIxMixin ):
  """ Concrete class implementing a sensor module based on the Pic18 mcu
  
  Use the .gpio_A .gpio_B .gpio_C members to use the ports in GPIO modes.
  
  Typical usage:
  >>> m.gpio_A.use(m.pins)
  >>> m.set_input(0)
  >>> import time
  >>> while True:
  >>>   m.gpio_A.put(255)
  >>>   time.sleep(0.2)
  >>>   m.gpio_A.put(0)
  >>>   time.sleep(0.2)
  """
  def __init__(self, nid, typecode, pna):
     SensorModule.__init__(self, nid, typecode, pna)
     MemIxMixin.__init__(self)
     self.mcu = P18F2680
     self.mem = MemInterface( self )
     self.gpio_A = Pic18GPIO([2,3,4,5,6,7,9,10],
       _get_port = self.mem_getterOf(self.mcu.PORTA),
       _set_latch = self.mem_setterOf(self.mcu.LATA),
       _set_tris = self.mem_setterOf(self.mcu.TRISA)    
       )
     self.gpio_B = Pic18GPIO(xrange(21,29),
       _get_port = self.mem_getterOf(self.mcu.PORTB),
       _set_latch = self.mem_setterOf(self.mcu.LATB),
       _set_tris = self.mem_setterOf(self.mcu.TRISB)
       )
     self.gpio_C = Pic18GPIO(xrange(11,19),
       _get_port = self.mem_getterOf(self.mcu.PORTC),
       _set_latch = self.mem_setterOf(self.mcu.LATC),
       _set_tris = self.mem_setterOf(self.mcu.TRISC)        
       )            

class GenericIO( Sensor_v16, MemAt0x1000):
  pass

class SensorNode_v06( Sensor_v16, MemAt0x1010):
  pass

class ServoModule( Module ):
  """
  Abstract superclass of servo modules. These support additional functionality 
  associated with position servos:

  .set_pos -- sets position of the module. -- units in 100s of degrees between 
    -9000 and 9000. This is a "safe" version, which only accepts legal values
  .set_pos_UNSAFE -- sets position of module, without any validity checking
  .get_pos -- reads current position (may be at offset from set_pos, even without load)
  .go_slack -- makes the servo go limp
  .is_slack -- return True if and only if module is slack
  """

  # (pure) Process message ID for set_pos process messages
  PM_ID_POS = None 

  # (pure) Magic value that makes the servo go slack
  POS_SLACK = 9001
  
  # (pure) Object Dictionary index of current "encoder" position 
  ENC_POS_INDEX = None
  
  # Upper limit for positions
  POS_UPPER = 9000
  
  # Lower limit for positions
  POS_LOWER = -9000
    
  def __init__(self, *argv, **kwarg):
    Module.__init__(self, *argv, **kwarg)
    self._attr=dict(
      go_slack="1R",
      is_slack="1R",
      get_pos="1R",
      set_pos="2W",
      set_pos_UNSAFE="2W"      
    )

  def go_slack(self):
    """
    Makes the servo go limp

    """
    self.set_pos_UNSAFE(self.POS_SLACK)

  def set_pos_UNSAFE(self, val):
    """
    Sets position of the module, without any validity checking
    
    INPUT:
      val -- units in 100s of degrees between -9000 and 9000
    """
    val = int(val)
    self.pna.send_pm(self.PM_ID_POS, 'h', val)
  
  def set_pos(self,val):
    """
    Sets position of the module, with safety checks.
    
    INPUT:
      val -- units in 100s of degrees between -9000 and 9000
    """
    self.set_pos_UNSAFE(crop(val,self.POS_LOWER,self.POS_UPPER))
  
    
  def get_pos_PM(self):
    """
    Gets the actual position of the module via process messages.

    OUTPUT:
      val -- list of positions -- units in 100s of degrees between -9000 and 9000
      time -- list of timestamps --
    """
    pass
    #TODO

  def get_pos(self):
    """
    Gets the actual position of the module
    """
    return self.pna.get_sync(self.ENC_POS_INDEX, 'h')

  def get_pos_async(self):
    """
    Asynchronously gets the actual position of the module
    """
    return self.pna.get_async(self.ENC_POS_INDEX)

  def is_slack(self):
    """
    Gets the actual position of the module
    """
    pos = self.pna.get_sync(self.POS_INDEX, 'h')
    return pos == self.POS_SLACK
    
class V1_3Module( ServoModule ):
  """
  Concrete subclass of Module for V1.3 modules.
  """
  PM_ID_POS = 0x100
  PM_ID_ENC_POS = 0x200
  ENC_POS_INDEX = 0x1051
  POS_INDEX = 0x1050

class V1_4Module( ServoModule ):
  """
  Concrete subclass of Module for V1.4 modules.
  """
  PM_ID_POS = 0x100
  PM_ID_ENC_POS = 0x200
  ENC_POS_INDEX = 0x1051
  POS_INDEX = 0x1050

class GenericModule( Module ):
  """
  Concrete subclass of Module used for modules whose typecode was not 
  recognized
  """
  def __init__(self, nid, typecode , pna):
    Module.__init__(self,nid,typecode,pna)
    warn( 
      RuntimeWarning("CAN node 0x%02X reported unknown typecode '%s'. Falling back on GenericModule class"% (nid, str(typecode))) 
    )
    
class MissingModule( Module ):
  """
  Concrete class representing required modules that were not discovered during
  the call to Cluster.populate
  
  Instances of this class "fake" servo and motor modules, and implement the 
  MemIx 
  
  """
  def __init__(self, nid, name):
    Module.__init__(self, nid, "<<filler>>", None)
    self.mem = MemInterface(self)
    self.mcu = object()
    self._mem = {}
    self.od = None
    self.msg = None
    self.nid = nid
    self.name = name
    self.slack = True
    self.pos = 0
    self.speed = 0
    self._attr=dict(
      go_slack="1R",
      is_slack="1R",
      get_pos="1R",
      set_pos="2W",
      get_speed="1R",
      set_speed="2W",
    )
    
  def get_od( self ):
    """get_od is not supported on MissingModule-s"""
    pass
  
  def mem_read( self, addr ):
    val = self._mem.get(addr,None)
    if val is None:
      self._mem[addr] = 0
      val = 0
    if self.msg is not None:
      self.msg("%s.mem[0x%04X] --> %d" % (self.name,addr,val))  
    return val
  
  def mem_write( self, addr, val ):
    self._mem[addr] = val
    if self.msg is not None:
      self.msg("%s.mem[0x%04X] <-- %d" % (self.name,addr,val))  
  
  def go_slack(self):
    self.slack = True
    self.speed = 0
    if self.msg is not None:
      self.msg("%s.go_slack()" % self.name )
      
  def is_slack(self):
    if self.msg is not None:
      self.msg("%s.is_slack() --> %s" % (self.name,str(self.slack)))  
    return self.slack
 
  def set_pos( self, val ):
    self.slack = False
    self.pos = val
    if self.msg is not None:
      self.msg("%s.set_pos(%d)" % (self.name,val))  
  
  def set_speed( self, val ):
    self.slack = False
    self.speed = val
    if self.msg is not None:
      self.msg("%s.set_speed(%d)" % (self.name,val))  
  
  def get_pos(self):
    if self.msg is not None:
      self.msg("%s.get_pos() --> %d" % (self.name,self.pos))  
    return self.pos
    
  def get_speed(self):
    if self.msg is not None:
      self.msg("%s.get_speed() --> %d" % (self.name,self.speed))  
    return self.speed
    
class MotorModule( Module ):
  """
  Abstract superclass of motor modules. These support additional functionality 
  associated with Motor Modules:

  .set_speed -- sets speed of the module -- units are RPM, range is +/-200
  """

  # (pure) Process message ID for set_speed process messages
  PM_ID_SPEED = None 

  # (pure) Upper limit for speed
  SPEED_UPPER = None
  
  # (pure) Lower limit for speed
  SPEED_LOWER = None
  
  # RPM to module speak conversion factor (x * RPM = -9000:9000)
  RPM_CONVERSION = 45

  def __init__(self, *argv, **kwarg):
    Module.__init__(self, *argv, **kwarg)
    self._attr=dict(
      set_speed="2W",
      go_slack="1R",
      set_speed_UNSAFE="2W"
    )

  def set_speed(self,val):
    """
    Sets speed of the module, with safety checks.
    
    INPUT:
      val -- units in between SPEED_LOWER and SPEED_UPPER
    """
    self.set_speed_UNSAFE(crop(val,self.SPEED_LOWER,self.SPEED_UPPER))
    
  def set_speed_UNSAFE(self, val):
    """
    Sets speed of the module, without any validity checking
    
    INPUT:
      val -- units in RPM  
    
    Do not use values outside the range SPEED_LOWER to SPEED_UPPER
    """
    # the 45 converts from RPM to +/- 9000 range the module expects
    val = int(self.RPM_CONVERSION*val)
    self.pna.send_pm(self.PM_ID_SPEED, 'h', val)

  def go_slack(self):
    """
    Makes the module go "slack": power down the motor.
    """
    # We send message directly because don't want RPM_CONVERSION to multiply it
    self.pna.send_pm(self.PM_ID_SPEED, 'h', self.SPEED_SLACK)
    
class ICRA_Motor_Module( MotorModule ):
  """
  Concrete subclass of Motor modules.
  """
  PM_ID_SPEED = 0x100
  SPEED_UPPER = 200
  SPEED_LOWER = -200
  SPEED_SLACK = 0
  
class Motor_Module_V1_0_MM( MotorModule ):
  """
  Concrete subclass of Motor modules.
  """
  PM_ID_SPEED = 0x100
  SPEED_UPPER = 9000/36
  SPEED_LOWER = -9000/36
  SPEED_SLACK = 9001
  RPM_CONVERSION = 36
  VEL_COMMAND_INDEX = 0x1030
  VEL_FEEDBACK_INDEX = 0x1031
  REL_POS_COMMAND_INDEX = 0x1032
  BRAKE_COMMAND_INDEX = 0x1033
  REL_POS_VELOCITY_CAP_INDEX = 0x1034
  RPM_FEEDBACK_INDEX = 0x1035
  
  def set_rel_pos(self, val):
    """
    Commands a relative position.
    
    INPUT:
        val -- units in between -32767 and 32767 (degrees * 100)
    """
    self.pna.set(self.REL_POS_COMMAND_INDEX, 'h', crop(val,-32767,32767))
    
  def set_servo_speed_cap_RPM(self, val):
    """
    Sets the maximum servo speed (speed when given a position command)
    
    INPUT:
        val -- RPM in between SPEED_LOWER and SPEED_UPPER
    """
    self.pna.set(self.REL_POS_VELOCITY_CAP_INDEX, 'h', crop(val*self.RPM_CONVERSION,self.SPEED_LOWER,self.SPEED_UPPER))
  
  def set_brake(self, val):
    """
    Sets the amount that the motor leads are tied together, therefore, braking
    
    INPUT:
      val -- number between 0 and 9000 where 9000 is always braking and 0 is never
    """
    self.pna.set(self.BRAKE_COMMAND_INDEX, 'h', crop(val,0,9000))
    
  def get_speed(self):
    """
    Gets the actual speed of the module in RPM
    """
    return self.pna.get_sync(self.RPM_FEEDBACK_INDEX, 'h')

  def get_speed_async(self):
    """
    Asynchronously gets the actual speed of the module in RPM
    """
    return self.pna.get_async(self.RPM_FEEDBACK_INDEX)
    
class IR_Node_Atx( Module, MemAt0x1010, MemIxMixin):
  """
    - IR Module Subclass. Has basic 'Module' functionality
        and should at some point have full memory access.
    - Will hopefully eventually have functions to deal with IR 
        communication and topology mapping. 
  """
  def __init__(self, nid, typecode, pna):
     Module.__init__(self, nid, typecode, pna)
     MemIxMixin.__init__(self)
     self.mcu = None
     self.mem = MemInterface( self )

#Register module types:
Module.Types['V1.3'] = V1_3Module
Module.Types['V1.4'] = V1_4Module
Module.Types['mm'] =ICRA_Motor_Module
Module.Types['V1.0-MM'] =Motor_Module_V1_0_MM
Module.Types['GenericIO'] =GenericIO
Module.Types['Sensor0.6'] =SensorNode_v06
Module.Types['Sensor0.2'] =SensorNode_v06
Module.Types['V0.1-ATX'] = IR_Node_Atx

##V: How to properly do this?
Module.Types['PolServoModule'] = pololu2_vv.PololuServoModule
