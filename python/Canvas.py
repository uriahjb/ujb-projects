"""
The widget handling Canvas wrapper for PyOpenGl and PyGame.

Canvas only handles widget objects.

Should eventually have some sweet functionality

"""

import string
import sys, os

# Import PyGame 
from pygame import init as pygame_init, quit as pygame_quit, display, event
from pygame.locals import *

# Import OpenGL 
try:
    from OpenGL.platform import win32
except AttributeError:
    pass

from OpenGL.GL import*
from OpenGL.GLU import*


"""
Info:
"""
__version__= string.split('$Revision 0.1 $')[1]
__data__ = string.join(string.split('$Date: 08/24/11 17:51::00 $')[1:3], ' ')
__author__ = 'Uriah Baalke <uriahjb@gmail.com>'


"""
The Canvas class 
... some description of its purpose ... 
... 
    something similar to, manages a network of gui widgets all within a single window 
    each with inputs and outputs ... linked to other widgets
...
"""
class Canvas( object ):
    
    DISPLAY_MODE = RESIZABLE|OPENGL|DOUBLEBUF

    """
    """
    def __init__( self, size=(200,200), position=(200,200) \
                       ,background=(0.0, 0.0, 0.0, 0.0) \
                       ,name='Default Canvas' ):
        """
        """
        # Size and position attributes
        self.size = size 
        self.position = position
        self.background = background

        # Initialize pygame and screen
        pygame_init()
        self.resize(*self.size)
        self.running = True
        self.run()

    def setup( self ):
        """
        A currently very hackish initialization ... should be made so that
        it is more customizable 
        """
        glClearColor(*self.background)
        glClearDepth(1.0)
        glDepthFunc(GL_LEQUAL)
        glEnable(GL_LIGHTING)
        glEnable(GL_LIGHT0)
        '''
        ambientLight = [0.2, 0.2, 0.2, 1.0]
        diffuseLight = [0.8, 0.8, 0.8, 1.0]
        specularLight = [0.5, 0.5, 0.5, 1.0]
        lightPos = [0.0, 0.0, -30.0, 1.0]
        glLightfv(GL_LIGHT0, GL_AMBIENT, ambientLight)
        glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuseLight)
        glLightfv(GL_LIGHT0, GL_SPECULAR, specularLight)
        glLightfv(GL_LIGHT0, GL_POSITION, lightPos)
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
        '''
        glEnable(GL_DEPTH_TEST)          # Enables Depth Testing
        glShadeModel(GL_SMOOTH)          # Enables smooth color shading
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()        
        # Set up perspective view
        gluPerspective(50.0, float(self.size[0])/float(self.size[1]), 0.1, 5000.0)
        # Set up an orthographic view
        #glOrtho(-float(width)/2, float(width)/2, -float(height)/2, float(height)/2, -1.0, 1.0)
        glMatrixMode(GL_MODELVIEW)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        display.flip() # For interactiveness sake
        return

    '''
    def beginOrtho( self ):
        """
        I get the sense that these are also hacks
        """
        glMatrixMode(GL_PROJECTION)
        glPushMatrix()
        glLoadIdentity()
        glOrtho(-float(800)/2, float(800)/2, -float(800)/2, float(800)/2, -1.0, 1.0)
        glMatrixMode(GL_MODELVIEW)
        glPushMatrix()
        glLoadIdentity()
        return

    def endOrtho( self ):
        """
        Another hack
        """
        glMatrixMode(GL_PROJECTION)
        glPopMatrix()
        glMatrixMode(GL_MODELVIEW)
        glPopMatrix()
        return
    '''
    
    def resize( self, width, height):
        """
        """
        self.size = (width, height)

        # This is painfully hacky, basically just remake the entire screen
        self.screen = display.set_mode((width, height), self.DISPLAY_MODE)
        # And reinitialize the GL context, ... ouch
        self.setup()

        # This is pretty normal
        if height == 0: height = 1

        glViewport(0, 0, width, height)
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        if (width <= height):
            glOrtho(-5.0, 5.0, -5.0*height/width, 
               5.0*height/width, -5.0, 5.0)
        else:
            glOrtho(-5.0*width/height, 
                     5.0*width/height, -5.0, 5.0, -5.0, 5.0)
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        return

    def _init_scene( self ):
        """
        """
        glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT)
        glLoadIdentity() 
        return
        
    def draw( self ):
        """
        """
        self._init_scene()
        # Begin Test
        self.__draw_quad()
        # End Test

        display.flip()
        return

    def __draw_quad( self ):
        # A quick quad drawer test
        glBegin(GL_QUADS)
        glVertex3f(-1.0, 1.0, 0.0)              # Top Left
        glVertex3f( 1.0, 1.0, 0.0)              # Top Right
        glVertex3f( 1.0,-1.0, 0.0)              # Bottom Right
        glVertex3f(-1.0,-1.0, 0.0)
        glEnd()
        return

    def handle_events( self ):
        """Generic event handling
        """
        for evnt in event.get():
            if evnt.type == QUIT:
                self.quit()                    
            if evnt.type == VIDEORESIZE:
                self.resize(*evnt.size)

    def run( self ):
        """
        """
        try:
            while self.running:
                self.handle_events()
                self.draw()
        except Exception, e:
            # Some sort of messy exception handling 
            print e 
        # Then exit properly 
        display.quit()
        pygame_quit()

    def quit( self ):
        """
        """
        self.running = False
    
    


