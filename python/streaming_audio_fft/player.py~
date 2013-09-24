#!/usr/bin/env python

# Playin some music

import ckbot.logical as L
from pylab import *
from time import time as now

c = L.Cluster()
c.populate(2)

#plucker_pos = 0.95 
plucker_pos = 0.8 
tuner_pos = -0.6
tuner_up = True

plucker = c.at.NxE3
tuner = c.at.Nx2A

notes_seq = tuner_pos + array([0.0, 0.2, 0.4, 0.2])
notes_seq2 = tuner_pos + array([0.8,0.0,0.2,0.8,0.2,-0.3,-0.8,-0.3])
notes_ind = 0

pluck_frq = 2.0 
pluck_t0 = now()

note_frq = 2.0
note_t0 = now()

while True:
  curtime = now()
  
  if (curtime - pluck_t0) > 1.0/pluck_frq:
    pluck_t0 = now()
    if tuner_up:
      plucker.set_pos( plucker_pos - 0.4 )
      tuner_up = False
    else:
      plucker.set_pos( plucker_pos )
      tuner_up = True

  if (curtime - note_t0) > 1.0/note_frq:
    note_t0 = curtime
    tuner.set_pos( notes_seq2[notes_ind] )
    notes_ind = (notes_ind+1) % len(notes_seq2)


       
    



