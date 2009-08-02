
import peasy.*;

PeasyCam cam;

static int FIXTURE_SIZE = 40;
static int NUM_FIXTURES = 70;
Fixture[] fixtureArray;

static int SOURCE_SIZE = 10;
static int NUM_SOURCES = 10;
Source[] sourceArray;

void setup()
{
  size(500, 500, P3D);

  // PeasyCam instructions:  
  // left click and drag to rotate camera
  // right click and drag to zoom
  // double click to reset to initial position
  // splat + left click and drag to pan (or 3rd mouse button and drag)

  cam = new PeasyCam(this, width/2, height/2, 500, 500);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);

  fixtureArray = new Fixture[NUM_FIXTURES];  
  for (int index=0; index<NUM_FIXTURES; ++index)
  {
    int x = (int)random(0, width);
    int y =  (int)random(0, height);  
    int z = (int)random(0, width);
    Fixture f = new Fixture(x, y, z); 
    fixtureArray[index] = f;
    println("Fixture at " + x + "," + y + "," + z);
  }
  
  sourceArray = new Source[NUM_SOURCES];  
  for (int index=0; index<NUM_SOURCES; ++index)
  {
    int x = (int)random(0, width);
    int y =  (int)random(0, height);  
    int z = (int)random(0, width);
    Source s = new Source(x, y, z); 
    sourceArray[index] = s;
    println("Source at " + x + "," + y + "," + z);
  }
  
}

void draw()
{
  
  computeUpdatedColors();
  
  background(0);
  noStroke();
  ambientLight(255, 255, 255);
  
  for (int i=0; i<NUM_SOURCES; ++i)
  {
    sourceArray[i].draw();
    sourceArray[i].randomMove();
    sourceArray[i].randomColorShift();
  }
  
  for (int i=0; i<NUM_FIXTURES; ++i)
  {
    fixtureArray[i].draw();
  }
}

void computeUpdatedColors()
{
  for (int i=0; i<NUM_FIXTURES; ++i)
  {
    fixtureArray[i].updateColors(sourceArray);
  }
}


class Fixture
{
  int x, y, z;
  color fixtureColor;
  
  
  Fixture(int xpos, int ypos, int zpos)
  {
    x = xpos;
    y = ypos;
    z = zpos;
  }
  
  void draw()
  {
    pushMatrix();
    noStroke();
    translate(x, y, z);
    fill(fixtureColor);
    box(FIXTURE_SIZE);
    popMatrix();
  }  
  
  void updateColors(Source[] sources)
  {
    float r, g, b;
    r = g = b = 0;
    for (int i=0; i<sources.length; ++i)
    {
      color c = sources[i].colorAtPoint(x, y, z);
      r += red(c);
      g += green(c);
      b += blue(c);
 
    }
    
    if (r > 255)
    {
      r = 255;
    }
    if (g > 255)
    {
      g = 255;
    }
    if (b > 255)
    {
      b = 255;
    }
    
    //println("\tr:" + r + ", g:" + g +", b:" + b);
    fixtureColor = color(r, g, b);
  }
}

class Source
{
  float x, y, z;
  float range;
  color c;
  
  Source(float xpos, float ypos, float zpos)
  {
    x = xpos;
    y = ypos;
    z = zpos;
    c = color(random(0, 255), random(0, 255), random(0, 255));
    range = 600.0;
  }
  
  void draw()
  {
    pushMatrix();
    noStroke();
    translate(x, y, z);
    fill(c);
    sphere(SOURCE_SIZE);
    popMatrix();
  }
  
  void randomMove()
  {
    x = random(x-5, x+5);
    y = random(y-5, y+5);
    z = random(z-5, z+5);
  }
  
  void randomColorShift()
  {
    int newR = (int)red(c) + (int)random(-5, 5);
    int newG = (int)green(c) + (int)random(-5, 5);
    int newB = (int)blue(c) + (int)random(-5, 5);
    c = color(newR, newG, newB);
  }
  
  color colorAtPoint(int xpos, int ypos, int zpos)
  {
    float distance = distanceTo(xpos, ypos, zpos);

    if (distance > range)
    {
      return color(0,0,0);
    }
    
    float percent = distance/range;
    
    // XXX - need a better falloff calculation  1/d^2 was what I thought would be correct 
    //   probably need to scale the distances by width/height/depth to get a percentage instead 
    float fallOff = 1.0 - percent;
    fallOff *= fallOff;
    //println("d:" + distance + " r: " + range + " p:" + percent);
 
    int r = (int)(red(c) * fallOff);
    int g = (int)(green(c) * fallOff);
    int b = (int)(blue(c) * fallOff);
    color newColor = color(r, g, b);
    
    //println("r: " + red(newColor) + ", g:" + green(newColor) + ", b:" + blue(newColor));
    return newColor;
  }
  
  float distanceTo(int xpos, int ypos, int zpos)
  {
    // manhattan distance, good enough
    float distance = abs(x - xpos);
    distance += abs(y-ypos);
    distance += abs(z-zpos);
    return distance;
  }
}

