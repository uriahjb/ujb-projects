"""
A canvas wrapper for PyOpenGl

Should eventually have some sweet functionality

"""

import string
import sys, os

try:
    from OpenGL.platform import win32
except AttributeError:
    pass

from OpenGL.GLUT import*
from OpenGL.GL import*
from OpenGL.GLU import*


"""
Info:
"""
__version__= string.split('$Revision 0.1 $')[1]
__data__ = string.join(string.split('$Date: 08/24/11 17:51::00 $')[1:3], ' ')
__author__ = 'Uriah Baalke <uriahjb@gmail.com>'


"""
The canvas class has the purpose to serve as wrapper for OpenGL, to handle user inputs,
and to communicate with GUI objects 
"""

class Canvas( object ):
    
    def __init__( self, width, height, x_pos=200, y_pos=200, name='Default Canvas' ):

        self.width = width
        self.height = height
        self.x_pos = x_pos
        self.y_pos = y_pos

        # Initialize basic glut properties, etc ...
        glutInit()
        glutInitDisplayMode(GLUT_RGBA | GLUT_DOUBLE | GLUT_DEPTH)
        glutInitWindowSize(width, height)
        glutInitWindowPosition(x_pos, y_pos)
        # Define reshape callback
        glutReshapeFunc(self.resize)
        # Define display callback
        glutDisplayFunc(self.display)
        # Define idle callback
        glutIdleFunc(self.idle)
        # Initialize window
        self.window = glutCreateWindow(name)
        self.setup()
        glutMainLoop()

    def setup( self ):
        """
        A currently very hackish initialization ... should be made so that
        it is more customizable 
        """
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
        gluPerspective(50.0, float(self.width)/float(self.height), 0.1, 5000.0)
        # Set up an orthographic view
        #glOrtho(-float(width)/2, float(width)/2, -float(height)/2, float(height)/2, -1.0, 1.0)
        glMatrixMode(GL_MODELVIEW)
        return

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

    def resize( self, width, height):
        self.width = width
        self.height = height

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
    
    def display( self ):
        pass

    def idle( self ):
        pass

    
    


