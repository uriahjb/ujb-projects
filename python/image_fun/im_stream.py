
# Get image from url in PIL format and convert to cv
from adaptors import*
import urllib2, cStringIO, cv, Image, time, pygame
screen = pygame.display.set_mode((500,500))
tic = time.time()
f = urllib2.urlopen('http://www.flash-slideshow-maker.com/images/help_clip_image020.jpg')
im_str = cStringIO.StringIO(f.read())
pi_im = Image.open(im_str)
cv_im = cv.CreateImageHeader(pi_im.size, cv.IPL_DEPTH_8U, 3)
cv.SetData(cv_im, pi_im.tostring())
cv_rgb = cv.CreateMat(cv_im.height, cv_im.width, cv.CV_8UC3)
cv.CvtColor(cv_im, cv_rgb, cv.CV_BGR2RGB)
pg_img = pygame.image.frombuffer(cv_rgb.tostring(), cv.GetSize(cv_rgb), "RGB")
screen.blit(pg_img, (0,0))
pygame.display.flip()
print time.time() - tic

# Looping
from adaptors import*
import urllib2, cStringIO, cv, Image, time, pygame
screen = pygame.display.set_mode((500,500))
while(1):
  tic = time.time()
  f = urllib2.urlopen('http://192.168.0.20/image.jpg')
  im_str = cStringIO.StringIO(f.read())
  pi_im = Image.open(im_str)
  cv_im = cv.CreateImageHeader(pi_im.size, cv.IPL_DEPTH_8U, 3)
  cv.SetData(cv_im, pi_im.tostring())
  cv_rgb = cv.CreateMat(cv_im.height, cv_im.width, cv.CV_8UC3)
  cv.CvtColor(cv_im, cv_rgb, cv.CV_BGR2RGB)
  pg_img = pygame.image.frombuffer(cv_rgb.tostring(), cv.GetSize(cv_rgb), "RGB")
  screen.blit(pg_img, (0,0))
  pygame.display.flip()
  print time.time() - tic

# I want to use pycurl apparently its faster
from adaptors import*
import urllib, StringIO, cv, Image, time, pygame, pycurl
im_str = StringIO.StringIO()
crl = pycurl.Curl()
crl.setopt(pycurl.URL, "http://192.168.0.20/image.jpg")
crl.setopt(pycurl.WRITEFUNCTION, im_str.write)
screen = pygame.display.set_mode((500,500))
while(1):	
  tic = time.time()
  crl.perform()
  pi_im = Image.open(im_str)
  cv_im = cv.CreateImageHeader(pi_im.size, cv.IPL_DEPTH_8U, 3)
  cv.SetData(cv_im, pi_im.tostring())
  cv_rgb = cv.CreateMat(cv_im.height, cv_im.width, cv.CV_8UC3)
  cv.CvtColor(cv_im, cv_rgb, cv.CV_BGR2RGB)
  pg_img = pygame.image.frombuffer(cv_rgb.tostring(), cv.GetSize(cv_rgb), "RGB")
  screen.blit(pg_img, (0,0))
  pygame.display.flip()
  print time.time() - tic

