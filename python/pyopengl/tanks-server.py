'''
   A game with tanks shooting each other
'''

#-------------------------------------------------------------------------
# Imports
#-------------------------------------------------------------------------
import sys, os, time
import math
import random
import numpy
import socket
import select

try:
  from OpenGL.GLUT import*
  from OpenGL.GL import*
  from OpenGL.GLU import*
except:
  print ''' PyOpenGL not installed properly '''
  sys.exit()

#-------------------------------------------------------------------------
# Global Settings
#-------------------------------------------------------------------------
ESCAPE = '\33'
window = 0
windowSize = [800, 800]
windowPosition = [400, 100]
timerPeriod = 10
MAX_BULLETS = 10
HIT_RADIUS = 12
tanks = []
blocks = []
BLOCK_LENGTH = windowSize[0]/35

#-------------------------------------------------------------------------
# A quick if a block intersects a circle function
#    note: currently only true for first quadrant, which is unexpected
#-------------------------------------------------------------------------
def square_circle_intersect(circle, block):
  dist_x = abs(circle.x - block.x) #- block.width/2) # I feel like this just shifts the coordinates
  dist_y = abs(circle.y - block.y) #- block.height/2)
  
  if (dist_x > (block.width/2 + circle.r)):
    return False
  if (dist_y > (block.height/2 + circle.r)):
    return False
  if (dist_x <= (block.width/2 + circle.r)):
    return True
  if (dist_y <= (block.height/2 + circle.r)):
    return True
  corner_dist = pow((dist_x - block.width/2),2) + pow((dist_y - block.height/2),2)
  return (corner_dist <= (pow(circle.r,2)))
  
#-------------------------------------------------------------------------
# Tank Class
#-------------------------------------------------------------------------
class Tank(object):

  def __init__(self, tank_number, state, mouse, body_dimensions, turret_dimensions, x, y, dx, dy, theta, dtheta, \
               turret_theta, turret_dtheta, color, translation_vel, rotation_vel, firing_period, reload_time,\
               health, num_bullets, bullets):
    self.r = HIT_RADIUS

    self.tank_number = tank_number
    self.state = state
    self.mouse = mouse
    self.body_dimensions = body_dimensions
    self.turret_dimensions = turret_dimensions
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
    self.theta = theta
    self.dtheta = dtheta
    self.turret_theta = turret_theta
    self.turret_dtheta = turret_dtheta
    self.color = color
    self.translation_vel = translation_vel
    self.rotation_vel = rotation_vel
    self.firing_period = firing_period
    self.reload_time = reload_time
    self.health = health
    self.num_bullets = num_bullets
    self.bullets = bullets
    return

  def draw(self):
  
    glPushMatrix()
    glColor3f(self.color[0], self.color[1], self.color[2])
    glTranslate(self.x, self.y, 0.0)
    glRotate(self.theta, 0.0, 0.0, 1.0)
    # Draw tank body
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    glBegin(GL_POLYGON)
    glVertex3f(self.body_dimensions[0]/2, self.body_dimensions[1]/2, 0.0) 
    glVertex3f(-self.body_dimensions[0]/2, self.body_dimensions[1]/2, 0.0)
    glVertex3f(-self.body_dimensions[0]/2, -self.body_dimensions[1]/2, 0.0)
    glVertex3f(self.body_dimensions[0]/2, -self.body_dimensions[1]/2, 0.0)
    glEnd()
    # Draw turret
    glRotate(self.turret_theta - self.theta, 0.0, 0.0, 1.0)
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    glBegin(GL_POLYGON)
    glVertex3f(0.0, self.turret_dimensions[1]/2, 0.0)
    glVertex3f(-self.turret_dimensions[0]/2, -self.turret_dimensions[1]/2, 0.0)
    glVertex3f(self.turret_dimensions[0]/2, -self.turret_dimensions[1]/2, 0.0)
    glEnd()
    glPopMatrix()      

    for n in range(len(self.bullets)):
      self.bullets[n].draw()
    return

  def animate(self):
    self.handle_state()    
    self.handle_mouse()
    self.check_collisions()
    # -------------------------------
    # Resolve position      
    # -------------------------------
    self.x += self.dx
    self.y += self.dy
    self.theta += self.dtheta
   
    for n in range(len(self.bullets)):
      self.bullets[n].animate()
    return
  
  def handle_state(self):
    # -------------------------------
    # Handle Keyboard Input Commands
    # -------------------------------
    # Firing
    if (self.state[2] == 'shooting'):
      if (self.state[3] == 'notReloading'):
        #print len(self.bullets)
        b = Bullet(self.x, self.y, 0, 0, self.turret_theta, 5, [1.0, 1.0, 1.0], 10, 0)
        if (self.num_bullets == MAX_BULLETS):
          self.num_bullets = 0
        if ((len(self.bullets)) > self.num_bullets):
          self.bullets.pop(self.num_bullets)
        self.bullets.append(b)
        self.num_bullets += 1
        self.state[3] = 'Reloading'
        self.reload_time = self.firing_period
     
    # Reloading
    if (self.state[3] == 'Reloading'):
      self.reload_time -= 1
      if (self.reload_time == 0):
        self.state[3] = 'notReloading'

    # Transformations
    if (self.state[1] == 'left'):
      self.dtheta = self.rotation_vel    
    elif (self.state[1] == 'right'):
      self.dtheta = -self.rotation_vel    
    else: 
      self.dtheta = 0.0 
    if (self.state[0] == 'forward'):
      self.dx = -self.translation_vel*math.sin(self.theta*math.pi/180) 
      self.dy = self.translation_vel*math.cos(self.theta*math.pi/180)
    elif (self.state[0] == 'backward'):  
      self.dx = self.translation_vel*math.sin(self.theta*math.pi/180) 
      self.dy = -self.translation_vel*math.cos(self.theta*math.pi/180)
    else:
      self.dx = 0.0
      self.dy = 0.0
    return  

  def handle_mouse(self):
    # -------------------------------
    # Handle Mouse Input
    # -------------------------------
    # Localize Coordinates 
    vec_x = -self.mouse[0] + self.x
    vec_y = self.mouse[1] - self.y 
    # Normalize
    magnitude = (math.sqrt(vec_y*vec_y + vec_x*vec_x))
    if (magnitude > 0.0):
      vec_x_norm = vec_x / magnitude
      vec_y_norm = vec_y / magnitude
    else: 
      vec_x_norm = 0.0
      vec_y_norm = 0.0
    self.turret_theta = -math.atan2(vec_y_norm, vec_x_norm)*(180/3.142) - 270
    return
  
  def check_collisions(self):
    for n in range(len(tanks)):
      # Check for hits from bullets
      if (n != self.tank_number):
        m = 0
        while(m < len(tanks[n].bullets)):
          r = math.hypot(tanks[n].bullets[m].x - self.x, tanks[n].bullets[m].y - self.y)
          # Check for bullet collision with tank
          if (r < HIT_RADIUS):
            self.health -= tanks[n].bullets[m].damage
            tanks[n].bullets.pop(m)
            print self.health
          # Check for bullet collision with block
          else:
            exit = False
            b = 0
            while((b < len(terrain.blocks)) and (exit == False)):
              if ((tanks[n].bullets[m].x < (terrain.blocks[b].x + BLOCK_LENGTH)) and \
                  (tanks[n].bullets[m].x > (terrain.blocks[b].x - BLOCK_LENGTH)) and \
                  (tanks[n].bullets[m].y < (terrain.blocks[b].y + BLOCK_LENGTH)) and \
                  (tanks[n].bullets[m].y > (terrain.blocks[b].y - BLOCK_LENGTH))):
                tanks[n].bullets.pop(m)            
                exit = True
              b += 1
          m += 1
      
      # Check for collisions with other tanks
      rr = math.hypot(tanks[n].x - self.x, tanks[n].y - self.y)
      if (rr < (2*HIT_RADIUS)):
        self.color = [1.0, 0.0, 0.0]
      else:
        self.color = [1.0, 1.0, 1.0]
      
      # Check for collisions with other blocks
      m = 0
      damping = 1.0
      while(m < len(terrain.blocks)):
        if (square_circle_intersect(self, terrain.blocks[m]) == True):
          self.color = [1.0, 0.0, 0.0]
          if (self.y > (terrain.blocks[m].y + terrain.blocks[m].height/2)):
            if (self.dy < 0):
              self.dy = -self.dy*damping
          if (self.y < (terrain.blocks[m].y - terrain.blocks[m].height/2)):
            if (self.dy > 0):
              self.dy = -self.dy*damping
          if (self.x > (terrain.blocks[m].x + terrain.blocks[m].width/2)):
            if (self.dx < 0):
              self.dx = -self.dx*damping
          if (self.x < (terrain.blocks[m].x - terrain.blocks[m].width/2)):
            if (self.dx > 0):
              self.dx = -self.dx*damping
        m+=1
    return
       
#-------------------------------------------------------------------------
# Bullet Class
#-------------------------------------------------------------------------
class Bullet(object):
  
  def __init__(self, x, y, dx, dy, theta, translation_vel, color, damage, lifetime):
    self.x = x
    self.y = y
    self.dx = dx
    self.dy = dy
    self.theta = theta
    self.translation_vel = translation_vel
    self.color = color
    self.damage = damage
    self.lifetime = lifetime
    return
 
  def draw(self):
    glPushMatrix()
    # Transform
    glColor3f(self.color[0], self.color[1], self.color[2])
    glTranslate(self.x, self.y, 0.0)
    glRotate(self.theta, 0.0, 0.0, 1.0)
    # Draw Bullet
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    glBegin(GL_POLYGON)
    #gluDisk(0.0, 1.0, 10, 1)
    glVertex3f(0.0, 3.0, 0.0)
    glVertex3f(-2.0, -2.0, 0.0)
    glVertex3f(2.0, -2.0, 0.0)
    glEnd()
    glPopMatrix()
    return

  def animate(self):
    self.dx = -self.translation_vel*math.sin(self.theta*3.14/180)
    self.dy = self.translation_vel*math.cos(self.theta*3.14/180)                 
    self.x += self.dx
    self.y += self.dy
    return

#-------------------------------------------------------------------------
# Terrain Class:
#      - handles generation of terrain, terrain 'animation, drawing, etc'
#-------------------------------------------------------------------------
class Terrain(object):
  def __init__(self, initialized, iterations, numBlocks, blockLength, blocks):
    self.iter = 0
    
    self.initialized = initialized
    self.iterations = iterations
    self.numBlocks = numBlocks
    self.blockLength = blockLength
    self.blocks = blocks
    return

  def draw(self):
    if (self.initialized == False):
      if (len(self.blocks) > 0):
        for n in range(len(self.blocks)):
          self.blocks.pop(self.numBlocks - n - 1)

      for n in range(self.numBlocks):
        cntnu = False
        while(cntnu == False):
          x_pos = 2*(random.randint(0, round(windowSize[0]/BLOCK_LENGTH)) - random.randint(0, round(windowSize[0]/BLOCK_LENGTH)))*BLOCK_LENGTH
          y_pos = 2*(random.randint(0, round(windowSize[1]/BLOCK_LENGTH)) - random.randint(0, round(windowSize[1]/BLOCK_LENGTH)))*BLOCK_LENGTH
          if (abs(x_pos) < abs(windowSize[0]/2) and abs(y_pos) < abs(windowSize[1])/2):
            cntnu = True
        b = t_block(n, 1, x_pos, y_pos, [1.0, 1.0, 1.0])
        self.blocks.append(b)
      self.iter += 1
      time.sleep(0.1)
      if (self.iter == self.iterations):
        self.initialized = True


    for n in range(len(self.blocks)):
      self.blocks[n].draw()
    return
  
  def animate(self):
    return
    

#-------------------------------------------------------------------------
# Terrain block
#   - All terrain is built by a bunch of squares with a fixed side length
#-------------------------------------------------------------------------
class t_block(object):
  def __init__(self, block_number, size, x, y, color):
    self.width = 2*BLOCK_LENGTH
    self.height = self.width

    self.block_number = block_number
    self.size = size
    self.x = x
    self.y = y
    self.color = color

  def draw(self):
    glPushMatrix()
    glColor3f(self.color[0], self.color[1], self.color[2])
    glTranslate(self.x, self.y, 0.0)
    # Draw a block
    glPolygonMode(GL_FRONT_AND_BACK, GL_LINE)
    glBegin(GL_POLYGON)
    glVertex3f(BLOCK_LENGTH*self.size, BLOCK_LENGTH*self.size, 0.0)
    glVertex3f(-BLOCK_LENGTH*self.size, BLOCK_LENGTH*self.size, 0.0)
    glVertex3f(-BLOCK_LENGTH*self.size, -BLOCK_LENGTH*self.size, 0.0)
    glVertex3f(BLOCK_LENGTH*self.size, -BLOCK_LENGTH*self.size, 0.0)
    glEnd()
    glPopMatrix()

# ------------------------------------------------------------------------------
# Server Class 
# ------------------------------------------------------------------------------

class gameServer(object):
    # ------------------------------------------------------------------------------
    # A serial->socket server: that allows multiple client processes
    #                          to use data from a single COM port
    # ------------------------------------------------------------------------------


    # ------------------------------------------------------------------------------
    # Initialize serialServer(with port, and with backlog) arguments
    #   which define what port the server is on and how many clients
    #   it will accept.
    # ------------------------------------------------------------------------------
    
    def __init__(self, port, backlog, serialFile):
                                
        # Initialize Server
        self.clients = 0
    
        #Output list
        self.server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.inputs = []
        self.outputs = []

        # Find an open port and use it
        portFound = False
        while(not portFound):        
            try:
                self.server.bind(('',port))
                portFound = True
            except:
                print "Port %s currently in use" %(port)
                port = port + 1
                print "Trying port: %s " %(port)


        print "Server initialized on port: %s" %(port)
        self.server.listen(backlog)
        
    # ------------------------------------------------------------------------------
    # runServer: using select to multiplex inputs and outputs 
    #
    # ------------------------------------------------------------------------------
    
    def Run(self):
      
      Run = True
      dataOut = ""
      junk = ""
      self.inputs = [self.server, sys.stdin]
      try:
        inputready, outputready, exceptready = select.select(self.inputs, self.outputs, [])
      except select.error, e:
        print "error server shutting down"
        self.server.close()
      except socket.error, e:
        print "error server shutting down"
        self.server.close()

      for sel in inputready:

        if sel == self.server:
          # Deal with server sockets
          (client, address) = self.server.accept()
          print "%s connected at %s" %(client.fileno(), address)
          self.clients += 1
          pipe = client.makefile('wr',0)
          self.inputs.append(pipe)
          self.outputs.append(pipe)
                    
        elif sel == sys.stdin:
          userInput = sys.stdin.readline()
          if userInput == "\n":
            print "Pretend shutdown"
            #Run = False
          else:
            for n in range(len(self.outputs)):
              self.outputs[n].write(userInput)
              for n in range(len(self.inputs)):
                print self.inputs[n]
                    
        else:
          print 'data'
          dataIn = sel.readline()
          if dataIn:
            print dataIn
          else:
            print "Client %s connection lost" %(sel.fileno())
            self.clients -= 1
            sel.close()
            self.inputs.remove(sel)
            self.outputs.remove(sel)
            
        #self.server.close()

#-------------------------------------------------------------------------
# Protype Start-up
#-------------------------------------------------------------------------

# Init Server
gameServer = gameServer(4559, 5, '')

numtanks = 2
for n in range(numtanks):
  t = Tank(n, ['notMoving', 'notRotating', 'notShooting', 'notReloading'], [0.0, 0.0], [20, 30], [10, 13], \
           0, 0, 0, 0, 0, 0, 0, 0, [1.0, 1.0, 1.0], 1, 3, 30, 0, 100, 0, [])
  tanks.append(t)

terrain = Terrain(False, 10, 75, windowSize[0]/35, [])

'''
numblocks = 50
for m in range(1):
  for n in range(numblocks):
    cntnu = False
    while(cntnu == False):
      x_pos = 2*(random.randint(0, round(windowSize[0]/BLOCK_LENGTH)) - random.randint(0, round(windowSize[0]/BLOCK_LENGTH)))*BLOCK_LENGTH
      y_pos = 2*(random.randint(0, round(windowSize[1]/BLOCK_LENGTH)) - random.randint(0, round(windowSize[1]/BLOCK_LENGTH)))*BLOCK_LENGTH
      if (abs(x_pos) < abs(windowSize[0]/2) and abs(y_pos) < abs(windowSize[1])/2):
        cntnu = True
    b = t_block(n, 1, x_pos, y_pos, [1.0, 1.0, 1.0])
    blocks.append(b)
'''
#-------------------------------------------------------------------------
# Initialize OpenGL and such
#-------------------------------------------------------------------------
def InitGL():
  values = []
  glGetFloatv (GL_LINE_WIDTH_GRANULARITY)
  glGetFloatv (GL_LINE_WIDTH_RANGE)
  glEnable (GL_LINE_SMOOTH)
  glEnable (GL_BLEND)
  glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  glHint (GL_LINE_SMOOTH_HINT, GL_DONT_CARE)
  position = [0.0, 0.0, -30.0, 1.0]
  glClearColor(0.0, 0.0, 0.0, 0.0) # Clears background to black
  glClearDepth(1.0)                # Enables clearing of depth buffer
  glDepthFunc(GL_LEQUAL)           # Type of depth test
  '''
  glLightfv(GL_LIGHT0, GL_POSITION, position)
  glEnable(GL_LIGHTING)
  glEnable(GL_LIGHT0)
  mat = [1.0, 0.0, 0.1, 1.0]
  '''
  glEnable(GL_DEPTH_TEST)          # Enables Depth Testing
  glShadeModel(GL_SMOOTH)          # Enables smooth color shading
  glMatrixMode(GL_PROJECTION)
  glLoadIdentity()
  # Set up perspective view
  #gluPerspective(50.0, float(width)/float(height), 0.1, 5000.0)
  # Set up an orthographic view
  glOrtho(-float(windowSize[0])/2, float(windowSize[0])/2, -float(windowSize[1])/2, float(windowSize[1])/2, -1.0, 1.0)
  glMatrixMode(GL_MODELVIEW)
  return      

#-------------------------------------------------------------------------
# Function called when window is resized
#-------------------------------------------------------------------------
def ResizeScene(width, height):
  if height == 0:
    height = 1
  
  glViewport(0, 0, width, height)
  glMatrixMode(GL_MODELVIEW)
  glLoadIdentity()
  # Set up perspective view
  #gluPerspective(45.0, float(width)/float(height), 0.1, 100.0)
  # Set up an orthographic view
  glOrtho(-float(width)/2, float(width)/2, -float(height)/2, float(height)/2, 10, -10)
  glMatrixMode(GL_MODELVIEW)
  return

#-------------------------------------------------------------------------
# A Function called when a key is pressed
#-------------------------------------------------------------------------
def keyPressed(*args):
  tank = tanks[0]  

  # Quit if escape is pressed
  if args[0] == ESCAPE:
    gameServer.server.close()
    sys.exit()
  
  if args[0] == 'a':
    tank.state[1] = 'left'
  if args[0] == 'd':
    tank.state[1] = 'right'
  if args[0] == 'w':
    tank.state[0] = 'forward'
  if args[0] == 's':
    tank.state[0] = 'backward'
  if args[0] == 'k':
    tank.state[2] = 'shooting'
  return

#-------------------------------------------------------------------------
# A Function called when a key is released
#-------------------------------------------------------------------------
def keyReleased(*args):
  tank = tanks[0]  

  if args[0] == 'w':
    tank.state[0] = 'none'
  if args[0] == 's':
    tank.state[0] = 'none'
  if args[0] == 'a':
    tank.state[1] = 'none'
  if args[0] == 'd':
    tank.state[1] = 'none'
  if args[0] == 'k':
    tank.state[2] = 'none'
  return

#-------------------------------------------------------------------------
# Mouse Function
#-------------------------------------------------------------------------
def Mouse(BUTTON, STATE, x, y):
  tank = tanks[0]
  if ((BUTTON == GLUT_LEFT_BUTTON) and (STATE == GLUT_DOWN)):   
    tank.state[2] = 'shooting'
  if ((BUTTON == GLUT_LEFT_BUTTON) and (STATE == GLUT_UP)):
    tank.state[2] = 'none'
  return

#-------------------------------------------------------------------------
# Passive Mouse Motion Function
#-------------------------------------------------------------------------
def mouseMotion(x, y):
  tank = tanks[0]
  tank.mouse[0] = x - (windowSize[0]/2)
  tank.mouse[1] = (windowSize[1]/2) - y 
  return

#-------------------------------------------------------------------------
# Timer Function
#-------------------------------------------------------------------------
def Timer(value):
  glutPostRedisplay()
  glutTimerFunc(timerPeriod, Timer, 1)
  return

#-------------------------------------------------------------------------
# Draw Function
#-------------------------------------------------------------------------
def Draw():
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
  glLoadIdentity()
  
  for n in range(len(tanks)):
    tanks[n].animate()
    tanks[n].draw()
  '''
  for n in range(len(blocks)):
    blocks[n].draw()
  '''
  
  terrain.draw() 
  
  glutSwapBuffers()
  return

def printer():
  print 'hello'

#-------------------------------------------------------------------------
# Main Function
#-------------------------------------------------------------------------
def main():
  global window  
  glutInit(sys.argv)
  # Double buffering is cool and what-not
  glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
  glutInitWindowSize(windowSize[0], windowSize[1])
  glutInitWindowPosition(windowPosition[0], windowPosition[1])
  window = glutCreateWindow("Killa Tankz")
  glutDisplayFunc(Draw)
  # Run server in spare cycles
  glutIdleFunc(gameServer.Run)
  glutReshapeFunc(ResizeScene)
  # Remove default cursor
  #glutSetCursor(GLUT_CURSOR_NONE) 
  # Processing Keyboard and Mouse
  glutKeyboardFunc(keyPressed)
  glutKeyboardUpFunc(keyReleased)
  glutPassiveMotionFunc(mouseMotion)
  glutMotionFunc(mouseMotion)
  glutMouseFunc(Mouse)
  # Set up timer
  glutTimerFunc(timerPeriod, Timer, 1)
  InitGL()
  # Main!
  glutMainLoop()

print "To quit press ESC"
main()
















