#!/usr/bin/env python

import pyaudio
from pylab import *
from time import time as now
from struct import unpack


# Initialize pyaudio streamer 
p = pyaudio.PyAudio()

chunk = 1024
seconds = 5

stream = p.open(format=pyaudio.paFloat32,
                channels=1,
                rate=44100,
                input=True,
                output=True)

# Set up realtime plotting
ion()

sample = 0
chunk = 1024
n_samples = xrange(0,chunk) 
data = zeros(chunk)

line, = plot( n_samples, data )

while True:
  new_data = stream.read( chunk )
  new_data = unpack( chunk*'f', new_data )
  new_samples = xrange( sample, sample+chunk )
  #data.append( new_data )
  #n_samples.append( new_samples )

  sample += chunk
  line.set_xdata( n_samples )
  line.set_ydata( new_data )
  draw()


