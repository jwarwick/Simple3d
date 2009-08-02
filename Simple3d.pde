import peasy.*;  // Processing camera library from http://mrfeinberg.com/peasycam/

// simple camera controls
  // PeasyCam instructions:  
  // left click and drag to rotate camera
  // right click and drag to zoom
  // double click to reset to initial position
  // splat + left click and drag to pan (or 3rd mouse button and drag)
PeasyCam cam;

// display window size
static int SCREEN_WIDTH = 500;
static int SCREEN_HEIGHT = 500;

// fixture definitions
static int NUM_FIXTURES = 200;
Fixture[] fixtureArray = new Fixture[NUM_FIXTURES];
static int FIXTURE_SIZE = 40;

// source definition
static int NUM_SOURCES = 7;
Source[] sourceArray = new Source[NUM_SOURCES];
static int SOURCE_SIZE = 10;


void setup()
{
  // size the display window
  size(SCREEN_WIDTH, SCREEN_HEIGHT, P3D);

  // PeasyCam(parent, lookAtX, lookAtY, lookAtXZ, distance) 
  cam = new PeasyCam(this, width/2, height/2, width/2, 1.5*width);

  // create the fixtures
  for (int index=0; index<fixtureArray.length; ++index)
  {
    Fixture f = new Fixture(new Position()); 
    fixtureArray[index] = f;
    //println("Fixture at " + f.position.toString());
  }
  
  // create the sources  
  for (int index=0; index<sourceArray.length; ++index)
  {
    //Source s = new Source(new Position());
    //Source s = new RandomSource(new Position());
    Source s = new SineSource(new Position());
    sourceArray[index] = s;
    //println("Source at " + s.position.toString());
  }
  
}

void draw()
{
  // update the color of each fixture
  for (int i=0; i<NUM_FIXTURES; ++i)
  {
    fixtureArray[i].updateColors(sourceArray);
  }
  
  background(0);
  noStroke();
  ambientLight(255, 255, 255);
  
  // draw the sources
  for (int i=0; i<sourceArray.length; ++i)
  {
    sourceArray[i].draw();
  }
  
  // draw the fixtures
  for (int i=0; i<fixtureArray.length; ++i)
  {
    fixtureArray[i].draw();
  }
 
  // update all the positions first, since the color depends on the position
  for (int i=0; i<sourceArray.length; ++i)
  {
    sourceArray[i].updatePosition();
  }

  for (int i=0; i<sourceArray.length; ++i)
  {
    sourceArray[i].updateColor();
  }
}


// class to hold location of objects and perform math on them
public class Position
{
  public float x, y, z;

  public Position(float xPos, float yPos, float zPos)  
  {
    x = xPos;
    y = yPos;
    z = zPos;
  }

  // generate a random position  
  public Position()
  {
     x = random(0, width);
     y = random(0, height);
     z = random(0, height);
  }
  
  public String toString()
  {
    return "(" + x + "," + y + "," + z + ")";
  }
  
  public void randomMove(float maxRange)
  {
    x = random(x-maxRange, x+maxRange);
    y = random(y-maxRange, y+maxRange);
    z = random(z-maxRange, z+maxRange);
  }
  
  // distance to another position instance
  public float distanceTo(Position targetPos)
  {
    // manhattan distance, good enough
    float distance = abs(x - targetPos.x);
    distance += abs(y - targetPos.y);
    distance += abs(z - targetPos.z);
    return distance;
  }
}


// object that displays a color
public class Fixture
{
  public Position position;
  public color fixtureColor;
  
  public Fixture(float xpos, float ypos, float zpos)
  {
    position = new Position(xpos, ypos, zpos);
  }
  
  public Fixture(Position p)
  {
    position = p;
  }
  
  public void draw()
  {
    pushMatrix();
    noStroke();
    translate(position.x, position.y, position.z);
    fill(fixtureColor);
    box(FIXTURE_SIZE);
    popMatrix();
  }  
  
  // the color of a fixture is determined by summing all input from the different sources
  // the color of a source is scaled based on it's distance
  public void updateColors(Source[] sources)
  {
    float r, g, b;
    r = g = b = 0;
    for (int i=0; i<sources.length; ++i)
    {
      // what color does this source impart on our position
      color c = sources[i].colorAtPoint(position);
      r += red(c);
      g += green(c);
      b += blue(c);
 
    }
    
    // keep everything in range
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
    
    fixtureColor = color(r, g, b);
  }
}


// object that generates a color
public class Source
{
  public Position position;
  public float range = 600.0;
  public color c = color(random(0, 255), random(0, 255), random(0, 255));
  
  public Source(float xpos, float ypos, float zpos)
  {
    position = new Position(xpos, ypos, zpos);
  }
  
  public Source(Position p)
  {
    position = p;
  }
  
  public void draw()
  {
    pushMatrix();
    noStroke();
    translate(position.x, position.y, position.z);
    fill(c);
    sphere(SOURCE_SIZE);
    popMatrix();
  }
  
  public void updatePosition()
  {
  }
  
  public void updateColor()
  {
  }
  
  public color colorAtPoint(Position targetPos)
  {
    float distance = position.distanceTo(targetPos);

    if (distance > range)
    {
      return color(0,0,0);
    }
    
    float percent = distance/range;
    float fallOff = 1.0 - percent;
    fallOff *= fallOff;
    
    if (fallOff > 1.0)
    {
      fallOff = 1.0;
    }
 
    int r = (int)(red(c) * fallOff);
    int g = (int)(green(c) * fallOff);
    int b = (int)(blue(c) * fallOff);
    return color(r, g, b);
  }
}

// a not very useful type of source, random small movements and color changes
public class RandomSource extends Source
{
  public RandomSource(Position p)
  {
    super(p);
  }
  
  public void updatePosition()
  {
    position.randomMove(5);
  }
  
  public void updateColor()
  {
    int newR = (int)red(c) + (int)random(-5, 5);
    int newG = (int)green(c) + (int)random(-5, 5);
    int newB = (int)blue(c) + (int)random(-5, 5);
    c = color(newR, newG, newB);
  }
}


// another type of source, with better movement
public class SineSource extends Source
{
  
  public int interval = 100; // in frames
  public float baseZ;
  
  public SineSource(Position p)
  {
    super(p);
    baseZ = position.z;
    
    interval = (int)random(2, 500);
  }
  
  public void updatePosition()
  {
    int frames = frameCount;
    float rem = frames % interval;
    float percent = rem/(float)(interval);
    float rad = (float)((2.0 * Math.PI) * percent);
    
    double s = sin(rad);
    float newZ = (float)(baseZ + (s * width/2));
    
    position.z = newZ;
  }
}
