#!/usr/bin/env python

"""
  IOMachine provides a class framework for a generic input output system, meant to be a superclass
  for state-machine and other generic classes. Its IO is linked to other IOMachine objects.

  The purpose of this is to develop a process/thread independent 'Input/Ouput Machine' for 
  purpose of generic and ... hopefully ... cool, multi-actor/entity interfacing. It would be nice
  to be able to do some sweet dynamic simulations or something.

  The above is representative of the desire for this system, and probably not really indicative 
  of its capabilities

  The top-level class is the IOMachine, it holds a dictionary of those IOMachine objects 
  which it sends to, and ... maybe holds a record of the IOMachine objects that have 
  sent it data. 
  
  All Input and Output structures are given a timestamp <--- of some sort
"""

class IOMachine( object ):
  
  """
  IOMachine class:
    has input and output lists
    - handles input list in Update method and passes resulting Messages to outputs

  """
  def __init__(self, inputs = [], outputs = [], \
                     input_addrs = {}, output_addrs = {}, \
                     prev_time = 0, cur_time = 0):
    """
    Initialize IOMachine
    """
    self.inputs = inputs
    self.outputs = outputs
    self.input_addrs = input_addrs   # Stores addresses of inputs with timestamp
    self.output_addrs = output_addrs  # Stores addresses of outputs with timestamp
    self.to_process = []
    self.prev_time = prev_time
    self.cur_time = cur_time
    

  def update(self, cur_time = 0):
    """
    Reads in messages from message queue based on timestamps and delay
       and updates input_addrs dict
    """

    for msg in self.inputs:
      # If timestamp and with delay are valid, then update inputs and push
      #   valid messages to to_process list
      if cur_time > (timestamp + delay):
        self.input_addrs[msg.sender_id] = cur_time
        self.to_process.append(msg)
    #
    return self.to_process

  def clean(self):
    """ 
    Clean out input messages that have been processed 
    """
    for msg in self.to_process:
     if msg.processed:
       self.to_process.remove(msg)
    #
    return self.to_process
          


class Message( object ):
  """
  Message class, serves to hold all necessary parameters for a given message
  
  INIT:
     sender_id -- id of sender
     ID -- message ID ... not sure what this is for yet
     data -- actual message data, maybe not a list?
     timestamp -- time of message send
     delay -- time it takes for message to be received

  """
  def __init__(self, sender_id = None, ID = None, data = [], timestamp = None, delay = None):
      self.sender_id = sender_id
      self.ID = ID
      self.data = data
      self.timestamp = timestamp
      self.delay = delay
      self.processed = False



