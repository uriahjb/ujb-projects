#!/usr/bin/python
# Filename: servoControl.py

# Controlling a Hitech servo using pyserial, hopefully eventually wirelessly

import serial
import sys, os, time

frameSize = 7

class servoControl(object):

    def __init__(self, com):
        # Set up serial with parameters defined by HiTech
        print 'Initializing Servo Communications'

        self.ser = serial.Serial(com)
        self.ser.baudrate = 19200
        self.ser.stopbits = 2
        self.ser.parity = 'N'

        self.id = []
        self.version = []
        self.pos_low = []
        self.pos_high = []

        self.current_response = []
    
    def get_id(self):
        # Currently just try and get version & id
        
        chk = 256 - (0x080 + 0xE7 + 0x00 + 0x00) % 256
        message = bytearray([0x80, 0xE7, 0x00, 0x00, chk, 0x00, 0x00])
        self.ser.write(message)

        response = self.get_response()

        self.version = response[5]
        self.id = response[6]
        
        self.current_response = response[5:7]
        

    def go(self):
        
        tx = [0x80, 0xEB, 0x00, 0x01];
        chk = 256 - sum(tx) % 256
        message = bytearray(tx + [chk, 0x00, 0x00])        
        self.ser.write(message)

        #response = self.get_response()
        #self.current_response = response[5:7]

    def stop(self):
        
        tx = [0x80, 0xEB, 0x00, 0x00];
        chk = 256 - sum(tx) % 256
        message = bytearray(tx + [chk, 0x00, 0x00])        
        self.ser.write(message)

        #response = self.get_response()
        #self.current_response = response[5:7]

    def set_pos(self, high, low):
               
        chk = 256 - (0x80 + 0xE6 + high + low) % 256
        message = bytearray([0x80, 0xE6, high, low, chk, 0x00, 0x00])        
        self.ser.write(message)

        #response = self.get_response()
        #self.current_response = response[5:7]


    def set_id(self, id):
        self.write_eeprom(0x29, id)


    def release(self):
        chk = 256 - (0x080 + 0xEF + 0x00 + 0x00) % 256
        message = bytearray([0x080, 0xEF, 0x00, 0x00, chk, 0x00, 0x00])
        self.ser.write(message)

        #response = self.get_response()

        self.current_response = response[5:7]


    # Define get_response utility function
    def get_response(self):
        waitfor = True
        while(waitfor): 
            if (self.ser.inWaiting() == frameSize): waitfor = False
        
        response = self.ser.read(frameSize)  
      
        return response
    
    # Read eeprom function
    def read_eeprom(self, addr):
        chk = 256 - (0x80 + 0xE1 + addr + 0x00) % 256  
        message = bytearray([0x080, 0xE1, addr, 0x00, chk, 0x00, 0x00])
        response = self.get_response()
        eeprom_data = response[5]
        print eeprom_data
        return eeprom_data
    
    # Write eeprom function
    def write_eeprom(self, addr, data):
        chk = 256 - (0x80 + 0xE2 + 0x29 + data) % 256
        response = self.get_response()
        print response[5]
        print response[6]
        


# End of servoControl.py

