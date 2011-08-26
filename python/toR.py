'''
to R. :
'''
if __name__ == '__build__':
    raise Exception

import string
__version__= string.split('$Revision 1.0 $')[1]
__data__ = string.join(string.split('$Date: 11/03/10 02:12:00 $')[1:3], ' ')
__author__ = 'Uriah Baalke <uriahjb@gmail.com>'

#-------------------------------------------------------------------------
import sys, os
sys.path += ['.']
import math
import random
#import weakref

from ctypes import util
try:
    from OpenGL.platform import win32
except AttributeError:
    pass

from OpenGL.GLUT import*
from OpenGL.GL import*
from OpenGL.GLU import*

ESCAPE = '\33'
window = 0
windowSize = [800, 800]
windowPos = [400, 100]

# Define Parameter Class
#-------------------------------------------------------------------------
class Parameters(object):
  def __init__(self, x, y, z, dx, dy, dz, red, green, blue\
               , alpha, gain, dGain, colorGain, density, cubeMax):
    self.x = x
    self.y = y
    self.z = z
    self.dx = dx
    self.dy = dy
    self.dz = dz
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha
    self.gain = gain
    self.dGain = dGain
    self.colorGain = colorGain
    self.density = density
    self.cubeMax = cubeMax

parameter = Parameters(20.0, 20.0, -300.0, 2.0, 0.0, -0.0, 0.5, 0.5, 0.5\
                       , 1.0, 1, 0.2, 0.5, 5, 0)

# Define Slider Class
#-------------------------------------------------------------------------
class Slider(object):
  def __init__(self, x, y, z, magnitude, visible):
    self.x = x
    self.y = y
    self.z = z
    self.magnitude = magnitude
    self.visible = visible
    
slider = []
for n in range(20):
  s = Slider(0.0, 0.0, 0.0, 0.0, 0)
  slider.append(s)

# Define Button Class
#-------------------------------------------------------------------------
class Button(object):
  def __init__(self, x, y, z, toggle, visible):
    self.x = x
    self.y = y
    self.z = z
    self.toggle = toggle
    self.visible = visible

button = []
for n in range(20):
  b = Button(0.0, 0.0, 0.0, 0, 0)
  button.append(b)

    
# Define gravityWell Class
#-------------------------------------------------------------------------
class GravWell(object):
  def __init__(self, x, y, z, strength):
    self.x = x
    self.y = y
    self.z = z
    self.strength = strength

gravWell = GravWell(0.0, 0.0, -300.0, 0.05)
# Define Cube Class
#-------------------------------------------------------------------------
class Cubez(object):
  def __init__(self, x, y, z, dx, dy, dz, theta, phi, psi, red, green, blue, alpha):
    self.x = x
    self.y = y
    self.z = z
    self.dx = dx
    self.dy = dy
    self.dz = dz
    self.theta = theta
    self.phi = phi
    self.psi = psi
    self.red = red
    self.green = green
    self.blue = blue
    self.alpha = alpha

cube = []
for n in range(5000):
  c = Cubez(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
  cube.append(c)

# Initialization Function
#-------------------------------------------------------------------------
def InitGL(width, height):
  glClearColor(0.0, 0.0, 0.0, 0.0)
  glClearDepth(1.0)
  glDepthFunc(GL_LEQUAL)
  glEnable(GL_LIGHTING);
  glEnable(GL_LIGHT0);
  ambientLight = [0.2, 0.2, 0.2, 1.0]
  diffuseLight = [0.8, 0.8, 0.8, 1.0]
  specularLight = [0.5, 0.5, 0.5, 1.0]
  lightPos = [0.0, 0.0, -30.0, 1.0]
  glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight);
  glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight);
  glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight);
  glLightfv(GL_LIGHT0, GL_POSITION, lightPos);
  glEnable(GL_LIGHTING)
  glEnable(GL_LIGHT0)

  mat = [1.0, 0.0, 0.1, 1.0]
  glMaterialfv(GL_FRONT, GL_AMBIENT, mat)
  mat[0] = 1.0; mat[1] = 0.0; mat[2] = 0.0
  glMaterialfv(GL_FRONT, GL_DIFFUSE, mat)
  mat[0] = 1.0; mat[1] = 1.0; mat[2] = 1.0
  glMaterialfv(GL_FRONT, GL_SPECULAR, mat)
  glMaterialf(GL_FRONT, GL_SHININESS, 0.6*128.0)
  glEnable(GL_FOG)
  fogColor = [1.0, 0.0, 1.0, 1.0]

  global fogMode
  fogMode = GL_EXP2
  glFogi (GL_FOG_MODE, fogMode)
  glFogfv (GL_FOG_COLOR, fogColor)
  glFogf (GL_FOG_DENSITY, 0.0001)
  glHint (GL_FOG_HINT, GL_NICEST)
  glFogf (GL_FOG_START, 10.0)
  glFogf (GL_FOG_END, -1000)
  glClearColor(0.0, 0.0, 0.1, 1.0)
  
  glEnable(GL_DEPTH_TEST)          # Enables Depth Testing
  glShadeModel(GL_SMOOTH)          # Enables smooth color shading
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  # Set up perspective view
  gluPerspective(50.0, float(width)/float(height), 0.1, 5000.0)
  # Set up an orthographic view
  #glOrtho(-float(width)/2, float(width)/2, -float(height)/2, float(height)/2, -1.0, 1.0)
  glMatrixMode(GL_MODELVIEW)
  return

# Begin Ortho
#-------------------------------------------------------------------------
def beginOrtho():
  glMatrixMode(GL_PROJECTION)
  glPushMatrix()
  glLoadIdentity()
  glOrtho(-float(800)/2, float(800)/2, -float(800)/2, float(800)/2, -1.0, 1.0)
  glMatrixMode(GL_MODELVIEW)
  glPushMatrix()
  glLoadIdentity()
  return

# End Ortho
#-------------------------------------------------------------------------
def endOrtho():
  glMatrixMode(GL_PROJECTION)
  glPopMatrix()
  glMatrixMode(GL_MODELVIEW)
  glPopMatrix()
  return
  

# Read Save File
#-------------------------------------------------------------------------
def ReadSaveFile():
  f = open('save/save.txt', 'r')
  parameter.x = float(f.readline())
  parameter.y = float(f.readline())
  parameter.z = float(f.readline())
  parameter.dx = float(f.readline())
  parameter.dy = float(f.readline())
  parameter.dz = float(f.readline())
  parameter.red = float(f.readline())
  parameter.green = float(f.readline())
  parameter.blue = float(f.readline())
  parameter.alpha = float(f.readline())
  parameter.gain = float(f.readline())
  parameter.dGain = float(f.readline())
  parameter.colorGain = float(f.readline())
  parameter.density = int(f.readline())
  gravWell.strength = float(f.readline())
  gravWell.z = float(f.readline())
  f.close()

# Write Save File
#-------------------------------------------------------------------------  
def WriteSaveFile():
  f = open('save/save.txt', 'w')
  f.write(str(parameter.x))
  f.write('\n')
  f.write(str(parameter.y))
  f.write('\n')
  f.write(str(parameter.z))
  f.write('\n')
  f.write(str(parameter.dx))
  f.write('\n')
  f.write(str(parameter.dy))
  f.write('\n')
  f.write(str(parameter.dz))
  f.write('\n')
  f.write(str(parameter.red))
  f.write('\n')
  f.write(str(parameter.green))
  f.write('\n')
  f.write(str(parameter.blue))
  f.write('\n')
  f.write(str(parameter.alpha))
  f.write('\n')
  f.write(str(parameter.gain))
  f.write('\n')
  f.write(str(parameter.dGain))
  f.write('\n')
  f.write(str(parameter.colorGain))
  f.write('\n')
  f.write(str(parameter.density))
  f.write('\n')
  f.write(str(gravWell.strength))
  f.write('\n')
  f.write(str(gravWell.z))
  f.write('\n')
  f.close()
  

# Function called when window is resized
#-------------------------------------------------------------------------
def ResizeScene(width, height):
  if height == 0:
    height = 1
  
  glViewport(0, 0, width, height)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  # Set up perspective view
  gluPerspective(45.0, float(width)/float(height), 0.1, 100.0)
  # Set up an orthographic view
  #glOrtho(-float(width)/2, float(width)/2, -float(height)/2, float(height)/2, 10, -10)
  glMatrixMode(GL_MODELVIEW)
  return


# Function called when a key is pressed.
#-------------------------------------------------------------------------
def keyPressed(*args):
  global cubeMax  
  # Quit is escape is pressed
  if args[0] == ESCAPE:
    WriteSaveFile()
    sys.exit()
  elif args[0] == '9':
    for n in range(parameter.cubeMax):
      cube[n].z += 10
    gravWell.z += 10
    print 'Distance from Well'
    print gravWell.z
  elif args[0] == '0':
    for n in range(parameter.cubeMax):
      cube[n].z -= 10
    gravWell.z -= 10
    print 'Distance from Well'
    print gravWell.z
  elif args[0] == '1':
    gravWell.strength = (gravWell.strength)*1.1
    print 'Well strength'
    print gravWell.strength
  elif args[0] == '2':
    gravWell.strength = (gravWell.strength)*0.9
    print 'Well strength'
    print gravWell.strength
  elif args[0] == 'a':
    print 'Make Cube x is:'
    print parameter.x
    parameter.x += 1
  elif args[0] == 'd':
    print 'Make Cube x is:'
    print parameter.x 
    parameter.x -= 1
  elif args[0] == 'w':
    print 'Make Cube y is:'
    print parameter.y 
    parameter.y += 1
  elif args[0] == 's':
    print 'Make Cube y is:'
    print parameter.y
    parameter.y -= 1
  elif args[0] == 'q':
    print 'Make Cube z is:'
    print parameter.z
    parameter.z -= 1
  elif args[0] == 'e':
    print 'Make Cube z is:'
    print parameter.z
    parameter.z += 1
  elif args[0] == 'i':
    print 'Make Cube dy is:'
    print parameter.dy
    parameter.dy += 0.2
  elif args[0] == 'k':
    print 'Make Cube dy is:'
    print parameter.dy
    parameter.dy -= 0.2
  elif args[0] == 'j':
    print 'Make Cube dx is:'
    print parameter.dx
    parameter.dx += 0.2
  elif args[0] == 'l':
    print 'Make Cube dx is:'
    print parameter.dx
    parameter.dx -= 0.2
  elif args[0] == 'u':
    print 'Make Cube dz is:'
    print parameter.dz
    parameter.dz += 0.2
  elif args[0] == 'o':
    print 'Make Cube dz is:'
    print parameter.dz
    parameter.dz -= 0.2
  elif args[0] == 'r':
    print 'Make Cube redish is:'
    print parameter.red
    if parameter.red <= 1.0:
      parameter.red += 0.05
  elif args[0] == 'f':
    print 'Make Cube redish is:'
    print parameter.red
    if parameter.red >= 0.0:
      parameter.red -= 0.05
  elif args[0] == 'g':
    print 'Make Cube greenish is:'
    print parameter.green
    if parameter.green <= 1.0:
      parameter.green += 0.05
  elif args[0] == 't':
    print 'Make Cube greenish is:'
    print parameter.green
    if parameter.green >= 0.0:
      parameter.green -= 0.05
  elif args[0] == 'b':
    print 'Make Cube blueish is:'
    print parameter.blue
    if parameter.blue <= 1.0:
      parameter.blue += 0.05
  elif args[0] == 'v':
    print 'Make Cube blueish is:'
    print parameter.blue
    if parameter.blue >= 0.0:
      parameter.blue -= 0.05
  elif args[0] == 'z':
    print 'Make Cube position noise gain is:'
    print parameter.gain
    parameter.gain += 0.1
  elif args[0] == 'x':
    print 'Make Cube position noise gain is:'
    print parameter.gain
    parameter.gain -= 0.1
    if parameter.gain < 0.1:
      parameter.gain = 0
  elif args[0] == 'm':
    print 'Make Cube velocity noise gain is:'
    print parameter.dGain
    parameter.dGain += 0.1
  elif args[0] == 'n':
    print 'Make Cube velocity noise gain is:'
    print parameter.dGain
    parameter.dGain -= 0.1
    if parameter.dGain < 0.1 and parameter.dGain > -0.1:
      parameter.dGain = 0
  elif args[0] == ',':
    print 'Make Cube color noise gain is:'
    print parameter.colorGain
    parameter.colorGain += 0.1
  elif args[0] == '.':
    print 'Make Cube color noise gain is:'
    print parameter.colorGain
    parameter.colorGain -= 0.1
  elif args[0] == ';':
    print 'Make Cube density is:'
    print parameter.density
    parameter.density -= 1
    if parameter.density < 1:
      parameter.density = 1
  elif args[0] == "'":
    print 'Make Cube density is:'
    print parameter.density
    parameter.density += 1
  elif args[0] == '3':
    print 'Clearing'
    parameter.cubeMax = 0
      
  elif args[0] == 'c':
    makeCube()
  elif args[0] == 'p':
    print "To quit press the ESC key"
    print "To make cubes press the 'c' key"
    print "To clear the cubes press 3"
    print "To see the keymapping and current state of parameters press 'p'"
    print "To zoom in and out use keys '9' and '0'"
    print "To increase or decrease the well strength use keys '1' and '2'"
    print 'Make Cube x is: [keys a/d]'
    print parameter.x
    print 'Make Cube y is: [keys w/s]'
    print parameter.y
    print 'Make Cube z is: [keys q/e]'
    print parameter.z
    print 'Make Cube dx is: [keys j/l]'
    print parameter.dx
    print 'Make Cube dy is: [keys i/k]'
    print parameter.dy
    print 'Make Cube dz is: [keys u/o]'
    print parameter.dz
    print 'Make Cube redish is: [keys r/f]'
    print parameter.red
    print 'Make Cube greenish is: [keys g/t]'
    print parameter.green
    print 'Make Cube blueish is: [keys b/v]'
    print parameter.blue
    print 'Make Cube position noise gain is: [keys z/x]'
    print parameter.gain
    print 'Make Cube velocity noise gain is: [keys m/n]'
    print parameter.dGain
    print 'Make Cube color noise gain is: [keys ./,]'
    print parameter.colorGain
    print "Make Cube density is: [keys ;,']"
    print parameter.density
  return
     
    
# make Cube definition
#-------------------------------------------------------------------------
def makeCube():
  for n in range(parameter.density):
    cube[parameter.cubeMax].x = parameter.x + (parameter.gain*(random.random() - random.random()))
    cube[parameter.cubeMax].y = parameter.y + (parameter.gain*(random.random() - random.random()))
    cube[parameter.cubeMax].z = parameter.z + (parameter.gain*(random.random() - random.random()))
    cube[parameter.cubeMax].dx = parameter.dx + (parameter.dGain*(random.random() - random.random()))
    cube[parameter.cubeMax].dy = parameter.dy + (parameter.dGain*(random.random() - random.random()))
    cube[parameter.cubeMax].dz = parameter.dz + (parameter.dGain*(random.random() - random.random()))
    cube[parameter.cubeMax].red = parameter.red + (parameter.colorGain*(random.random() - random.random()))
    cube[parameter.cubeMax].green = parameter.green + (parameter.colorGain*(random.random() - random.random()))
    cube[parameter.cubeMax].blue = parameter.blue + (parameter.colorGain*(random.random() - random.random()))
    cube[parameter.cubeMax].alpha = parameter.alpha + (parameter.colorGain*(random.random() - random.random()))
    parameter.cubeMax += 1
  return

# Drawing Function
#-------------------------------------------------------------------------
def drawCoolz():
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  glLoadIdentity()
  beginOrtho()
  # Draw Sliders
  for n in xrange(len(slider)):
    if (slider[n].visible == 1):
      drawSlider(n)
  for n in xrange(len(button)):
    if (button[n].visible == 1):
      drawButton(n)
  endOrtho()
  drawLaunchSphere()
  glPushMatrix()
  glTranslate(gravWell.x, gravWell.y, gravWell.z)
  material = [1.0, 1.0, 1.0]
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, material)
  glutWireSphere(0.1, 10, 10)
  glPopMatrix()
  
  # Put object draws, etc here....
  for n in xrange(parameter.cubeMax):
    drawCube(n)
    animateCube(n)
    
  updateSliderParameters()
  updateButtonParameters()
  glutPostRedisplay()
  glutSwapBuffers()
  return

# Draw Launch Sphere
#-------------------------------------------------------------------------
def drawLaunchSphere():
  glPushMatrix()
  glTranslate(parameter.x, parameter.y, parameter.z)
  glutWireSphere(0.1, 10, 10)
  glPopMatrix()
  return

# Draw Slider
#-------------------------------------------------------------------------
def drawSlider(sliderNum):
  glPushMatrix()
  glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
  material = [1.0, 1.0, 1.0]
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, material)
  glTranslate(slider[sliderNum].x, slider[sliderNum].y, 0.0)
  glBegin(GL_POLYGON)
  glVertex3f(0.0, 10.0, 0.0)
  glVertex3f(100.0, 10.0, 0.0)
  glVertex3f(100.0,  0.0, 0.0)
  glVertex3f(0.0, 0.0, 0.0)
  glEnd()
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
  material = [1.0, 1.0, 1.0]
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, material)
  glTranslate(slider[sliderNum].magnitude, 0.0, 0.0)
  glBegin(GL_POLYGON)
  glVertex3f(0.0, 10.0, 0.0)
  glVertex3f(10.0, 10.0, 0.0)
  glVertex3f(10.0,  0.0, 0.0)
  glVertex3f(0.0, 0.0, 0.0)
  glEnd()
  glPopMatrix() 
  return

# Draw Button
#-------------------------------------------------------------------------
def drawButton(buttonNum):
  glPushMatrix()
  if (button[buttonNum].toggle == 1):
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
  else:
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
  material = [1.0, 1.0, 1.0]
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, material)
  glTranslate(button[buttonNum].x, button[buttonNum].y, 0.0)
  glBegin(GL_POLYGON)
  glVertex3f(0.0, 10.0, 0.0)
  glVertex3f(10.0, 10.0, 0.0)
  glVertex3f(10.0,  0.0, 0.0)
  glVertex3f(0.0, 0.0, 0.0)
  glEnd()
  glPopMatrix()
  return
  

# Draw Cubez
#-------------------------------------------------------------------------
def drawCube(cubeNumber):
  glPushMatrix()
  glTranslate(cube[cubeNumber].x, cube[cubeNumber].y, cube[cubeNumber].z)
  glRotate(cube[cubeNumber].theta, cube[cubeNumber].x, cube[cubeNumber].y, cube[cubeNumber].z)
  glRotate(cube[cubeNumber].phi, cube[cubeNumber].x, cube[cubeNumber].y, cube[cubeNumber].z)
  glRotate(cube[cubeNumber].psi, cube[cubeNumber].x, cube[cubeNumber].y, cube[cubeNumber].z)
  glPolygonMode(GL_FRONT_AND_BACK, GL_FILL)
  material = [cube[cubeNumber].red, cube[cubeNumber].green, cube[cubeNumber].blue, cube[cubeNumber].alpha]
  glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE, material)
  glutSolidCube(1.0)
  glPopMatrix()
  return

# Animate Cubez
#-------------------------------------------------------------------------
def animateCube(cubeNumber):
  R = math.sqrt((gravWell.x - cube[cubeNumber].x)*(gravWell.x - cube[cubeNumber].x)\
                +(gravWell.y - cube[cubeNumber].y)*(gravWell.y - cube[cubeNumber].y)\
                +(gravWell.z - cube[cubeNumber].z)*(gravWell.z - cube[cubeNumber].z))
  Fx = (cube[cubeNumber].x - gravWell.x)*gravWell.strength/R
  Fy = (cube[cubeNumber].y - gravWell.y)*gravWell.strength/R
  Fz = (cube[cubeNumber].z - gravWell.z)*gravWell.strength/R
  cube[cubeNumber].dx = cube[cubeNumber].dx - Fx
  cube[cubeNumber].dy = cube[cubeNumber].dy - Fy
  cube[cubeNumber].dz = cube[cubeNumber].dz - Fz
  cube[cubeNumber].x = cube[cubeNumber].x + cube[cubeNumber].dx
  cube[cubeNumber].y = cube[cubeNumber].y + cube[cubeNumber].dy
  cube[cubeNumber].z = cube[cubeNumber].z + cube[cubeNumber].dz
  cube[cubeNumber].theta = cube[cubeNumber].theta + 5.0
  cube[cubeNumber].phi = cube[cubeNumber].phi + 5.0
  return

# Mouse Function
#-------------------------------------------------------------------------
def mouse(BUTTON, STATE, x, y):
  x = x - 400
  y = 400 - y
  if ((BUTTON == GLUT_LEFT_BUTTON) and (STATE == GLUT_DOWN)):
    for n in xrange(len(slider)):
      if (slider[n].visible == 1):
        if ((x > (slider[n].x-5)) and (x < (slider[n].x+95)) \
            and (y > (slider[n].y-10)) and (y < (slider[n].y+10))):
          slider[n].magnitude = x - slider[n].x
        if ((x < (slider[n].x+2)) \
            and (y > (slider[n].y-10)) and (y < (slider[n].y+10))):
          slider[n].magnitude = 0
    for m in xrange(len(button)):
      if (button[m].visible ==  1):
        if ((x > (button[m].x-10)) and (x < (button[m].x+10)) \
            and (y > (button[m].y-10)) and (y < (button[m].y+10))):
          if (button[m].toggle == 1):
            button[m].toggle = 0
          elif (button[m].toggle == 0):
            button[m].toggle = 1
  return    

# Define Sliders and parameters
#-------------------------------------------------------------------------
def updateSliderParameters():
  parameter.red = (slider[0].magnitude/100.0)
  parameter.green = (slider[1].magnitude/100.0)
  parameter.blue = (slider[2].magnitude/100.0)
  parameter.colorGain = (slider[3].magnitude/500.0)
  parameter.gain = (slider[4].magnitude/10.0)
  parameter.dGain = (slider[5].magnitude/200.0)
  parameter.density = (slider[6].magnitude*4)
  if (parameter.density == 0):
    parameter.density = 1
  parameter.dx = (slider[7].magnitude/20.0)-2.5
  parameter.dy = (slider[8].magnitude/20.0)-2.5
  parameter.dz = (slider[9].magnitude/20.0)-2.5
  #parameter.z = (slider[10].magnitude) 
  gravWell.strength = (slider[14].magnitude/50.0)
  return

# Init Sliders
#-------------------------------------------------------------------------
def InitSliders():
  slider[0].magnitude = parameter.red*100.0
  slider[1].magnitude = parameter.green*100.0
  slider[2].magnitude = parameter.blue*100.0
  slider[3].magnitude = parameter.colorGain*500.0
  slider[4].magnitude = parameter.gain*10.0
  slider[5].magnitude = parameter.dGain*200.0
  slider[6].magnitude = parameter.density/4
  slider[7].magnitude = ((parameter.dx+2.5)*20)
  slider[8].magnitude = ((parameter.dy+2.5)*20)
  slider[9].magnitude = ((parameter.dz+2.5)*20)
  #slider[10].magnitude = ((parameter.z))
  slider[14].magnitude = gravWell.strength*50.0
  y = 380
  for n in range(15):
    slider[n].visible = 1
    slider[n].x = -390
    slider[n].y = y
    y -= 20
  return


# Update Buttons
#-------------------------------------------------------------------------
def updateButtonParameters():
  if (button[0].toggle == 1):
    makeCube()
  if (button[1].toggle == 1):
    parameter.cubeMax = 0
    button[1].toggle = 0
  if (button[5].toggle == 1):
    WriteSaveFile()
    sys.exit()
  return

# Init Buttons
#-------------------------------------------------------------------------
def InitButtons():
  y = 380
  for n in range(5):
    button[n].visible = 1
    button[n].x = -280
    button[n].y = y
    y -= 20
  button[n+1].visible = 1
  button[n+1].x = 380
  button[n+1].y = 380
  return

# Main!
#-------------------------------------------------------------------------
def main():
  global window  
  glutInit(sys.argv)
  # Double buffering is cool and what-not
  glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
  glutInitWindowSize(windowSize[0], windowSize[1])
  glutInitWindowPosition(windowPos[0], windowPos[1])
  window = glutCreateWindow("to R")
  glutDisplayFunc(drawCoolz)
  glutIdleFunc(drawCoolz)
  glutReshapeFunc(ResizeScene)
  # Processing Keyboard
  glutKeyboardFunc(keyPressed)
  # Processing Mouse
  glutMouseFunc(mouse)
  InitGL(windowSize[0], windowSize[1])
  ReadSaveFile()
  InitSliders()
  InitButtons()
  # Main!
  glutMainLoop()
  

print "To quit press the ESC key"
print "To make cubes press the 'c' key"
print "To clear the cubes press 3"
print "To see the keymapping and current state of parameters press 'p'"
print "To zoom in and out use keys '9' and '0'"
print "To increase or decrease the well strength use keys '1' and '2'"
print 'Make Cube x is: [keys a/d]'
print parameter.x
print 'Make Cube y is: [keys w/s]'
print parameter.y
print 'Make Cube z is: [keys q/e]'
print parameter.z
print 'Make Cube dx is: [keys j/l]'
print parameter.dx
print 'Make Cube dy is: [keys i/k]'
print parameter.dy
print 'Make Cube dz is: [keys u/o]'
print parameter.dz
print 'Make Cube redish is: [keys r/f]'
print parameter.red
print 'Make Cube greenish is: [keys g/t]'
print parameter.green
print 'Make Cube blueish is: [keys b/v]'
print parameter.blue
print 'Make Cube position noise gain is: [keys z/x]'
print parameter.gain
print 'Make Cube velocity noise gain is: [keys m/n]'
print parameter.dGain
print 'Make Cube color noise gain is: [keys ./,]'
print parameter.colorGain
print "Make Cube density is: [keys ;,']"
print parameter.density
main()
