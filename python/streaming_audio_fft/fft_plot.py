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
chunk = 4096 
n_samples = arange(chunk) 
data = zeros(chunk)

n_samples2 = range(chunk/2)

sampling_rate = 44100.0
T = chunk/sampling_rate
frq = n_samples/T # two sides frequency range
frq = frq[n_samples2] # one side frequency range

max_fft_val = 0.0
min_fft_val = 0.0

line, = plot( n_samples, data )
axis( [min(frq), max(frq), max_fft_val, min_fft_val] )


while True:
  new_data = stream.read( chunk )
  new_data = unpack( chunk*'f', new_data )
  new_samples = xrange( sample, sample+chunk )
  #data.append( new_data )
  #n_samples.append( new_samples )
  fft_dat = fft( new_data )/chunk
  fft_dat = fft_dat[n_samples2]

  max_fft_val = max( max(fft_dat), max_fft_val )
  #min_fft_val = max( min(fft_dat), min_fft_val )
  axis( [min(frq), max(frq), min_fft_val, max_fft_val] )
  
  sample += chunk
  line.set_xdata( frq )
  line.set_ydata( abs(fft_dat) )
  draw()


