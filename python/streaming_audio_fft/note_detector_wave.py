#!/usr/bin/env python

import pyaudio
import wave
from pylab import *
from time import time as now
from struct import unpack

BASE_FRQ = 261.6 

def frq2note( frq ):
  return 12*log2( frq/BASE_FRQ )

def note2frq( note ):
  return pow(2, note/12.0)*BASE_FRQ

# Notes
notes_seq = array(['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'])

max_frq = 5000


# Initialize pyaudio streamer 
p = pyaudio.PyAudio()
wf = wave.open( 'Estringtuning.wav', 'rb')
sampling_rate = wf.getframerate()
num_channels = wf.getnchannels()
sample_width = wf.getsampwidth()
num_frames = wf.getnframes()

stream = p.open(format =
                p.get_format_from_width(sample_width),
                channels = num_channels,
                rate = sampling_rate,
                output = True)

# Set up realtime plotting
ion()

sample = 0
chunk = 10*1024 
#chunk = num_frames
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

total_samples = chunk * num_channels

if sample_width == 1: 
  fmt = "%iB" % total_samples # read unsigned chars
elif sample_width == 2:
  fmt = "%ih" % total_samples # read signed 2 byte shorts
else:
  raise ValueError("Only supports 8 and 16 bit audio formats.")
print 'fmt: ', fmt 

while True:
  raw_data = wf.readframes( chunk )
  if len(raw_data) < sample_width*total_samples:
    break
  new_data = unpack( fmt, raw_data )

  # playback data as read
  #stream.write( raw_data )
  #new_data = stream.read( chunk )
  #new_data = unpack( chunk*'f', new_data )
  #new_samples = xrange( sample, sample+chunk )
  #data.append( new_data )
  #n_samples.append( new_samples )
  fft_dat = fft( new_data )/chunk
  fft_dat = fft_dat[n_samples2]

  inds = argsort( fft_dat.real )

  #print 'fft_mag: ', abs(fft_dat[inds[:5]].real)

  sorted_frqs = frq[inds]
  sorted_frqs = sorted_frqs[sorted_frqs < max_frq]
  top_n = 3 
  est_note = frq2note( sorted_frqs[:top_n] )
  closest_note = around( est_note )
  note_diff = est_note - closest_note 
  note_diff_s = [str(el) for el in note_diff]

  # threshold magnitude  
  thresh = 1500.0
  if abs(fft_dat[inds[0]].real) > thresh:
    notes_seq_str = notes_seq[int32(closest_note) % len(notes_seq)]
    notes_str = [s0+s1 for s0,s1 in zip(notes_seq_str, note_diff_s)]
    print 'notes: ', notes_str

  #print 'max_freqs: ', sorted_frqs[:5]

  max_fft_val = max( max(abs(fft_dat)), max_fft_val )
  #min_fft_val = max( min(fft_dat), min_fft_val )
  axis( [min(frq), max_frq, min_fft_val, max_fft_val] )
  
  sample += chunk
  line.set_xdata( frq )
  line.set_ydata( abs(fft_dat) )
  draw()


