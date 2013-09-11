#!/usr/bin/env python

import pyaudio
from pylab import *
from time import time as now
from struct import unpack
import matplotlib.mlab as mlab

notes_tbl = array([ 16.35, 17.32, 18.35, 19.45, 20.6 , 21.83, 23.12, 24.5, 25.96, 27.5 , 29.14, 30.87])

_,scl = mgrid[1:len(notes_tbl)+1, 1:len(notes_tbl)+1]


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
window = 5*44100
T = chunk/sampling_rate
frq = n_samples/T # two sides frequency range
frq = frq[n_samples2] # one side frequency range

max_fft_val = 0.0
min_fft_val = 0.0

#line, = plot( n_samples, data )
#axis( [min(frq), max(frq), max_fft_val, min_fft_val] )

#fig = figure()
#ax = fig.add_subplot(111)

first_image = True
data = []

while True:
  new_data = stream.read( chunk )
  new_data = unpack( chunk*'f', new_data )
  if len(data) > window:
    data = data[len(data)-window:]

  data = hstack( (data, new_data) )
  new_samples = xrange( sample, sample+chunk )
  
  pxx, frq, bins = mlab.specgram(data, Fs=sampling_rate)

  if first_image:
    pxx_mod = 10*log10(pxx)
    extent = (bins[0], bins[-1], frq[0], frq[-1])
    img = imshow( pxx_mod )
    ax = img.get_axes()
    ax.set_aspect('auto')
    img.set_extent( extent )

    first_image = False

  pxx_mod = 10*log10(pxx)
  img.set_data( pxx_mod )
  draw()
  #data.append( new_data )
  #n_samples.append( new_samples )
  #fft_dat = fft( new_data )/chunk
  #fft_dat = fft_dat[n_samples2]

  #max_fft_val = max( max(fft_dat), max_fft_val )
  #min_fft_val = max( min(fft_dat), min_fft_val )
  #axis( [min(frq), max(frq), min_fft_val, max_fft_val] )
  
  #sample += chunk
  #line.set_xdata( frq )
  #line.set_ydata( abs(fft_dat) )
  #draw()


