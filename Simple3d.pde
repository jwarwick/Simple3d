import peasy.*;  // Processing camera library from http://mrfeinberg.com/peasycam/

// simple camera controls
  // PeasyCam instructions:  
  // left click and drag to rotate camera
  // right click and drag to zoom
  // double click to reset to initial position
  // splat + left click and drag to pan (or 3rd mouse button and drag)
PeasyCam cam;

// display window size
final int SCREEN_WIDTH = 500;
final int SCREEN_HEIGHT = 500;

// fixture definitions
final int NUM_FIXTURES = 200;
Fixture[] fixtureArray = new Fixture[NUM_FIXTURES];
final int FIXTURE_SIZE = 40;

// source definition
final int NUM_SOURCES = 7;
Source[] sourceArray = new Source[NUM_SOURCES];
final int SOURCE_SIZE = 10;


void setup()
{
  // size the display window
  size(SCREEN_WIDTH, SCREEN_HEIGHT, P3D);

  // PeasyCam(parent, lookAtX, lookAtY, lookAtXZ, distance) 
  cam = new PeasyCam(this, width/2, height/2, width/2, 1.5*width);

  // create the fixtures
  for (int index=0; index<fixtureArray.length; ++index)
  {
    Fixture f = new Fixture(); 
    fixtureArray[index] = f;
    //println("Fixture at " + f.position.toString());
  }
  
  // create the sources  
  for (int index=0; index<sourceArray.length; ++index)
  {
    //Source s = new Source();
    //Source s = new RandomSource();
    //Source s = new SineSource();
    Source s = new PulseSource();
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
  if (shouldDrawSources())
  {
    for (int i=0; i<sourceArray.length; ++i)
    {
      sourceArray[i].draw();
    }
  }
  
  // draw the fixtures
  if (shouldDrawFixtures())
  {
    for (int i=0; i<fixtureArray.length; ++i)
    {
      fixtureArray[i].draw();
    }
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

boolean shouldDrawSources()
{
  return !(keyPressed && ((key == 's' || key == 'S')));
}

boolean shouldDrawFixtures()
{
  return !(keyPressed && ((key == 'f' || key == 'F')));
}

// class to hold location of objects and perform math on them
public class Position
{
  // the current location
  public float x, y, z;
  
  // the start location, set on creation
  final public float startX, startY, startZ;

  public Position(float xPos, float yPos, float zPos)  
  {
    x = xPos;
    y = yPos;
    z = zPos;
    startX = x;
    startY = y;
    startZ = z;
  }

  // generate a random position  
  public Position()
  {
     this(random(0, width), random(0, height), random(0, height));
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
  
  public Fixture(Position p)
  {
    position = p;
  }
  
  public Fixture()
  {
    this(new Position());
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
  public float range;
  public color c;
  
  public Source(Position p, float rng, color clr)
  {
    position = p;
    range = rng;
    c = clr;
  }
  
  public Source(Position p)
  {
    this(p, random(100, 600), color(random(0, 255), random(0, 255), random(0, 255)));
  }
  
  public Source()
  {
    this(new Position(), random(100, 600),
      color(random(0, 255), random(0, 255), random(0, 255)));
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
  public RandomSource()
  {
    super();
  }
  
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
  final public int intervalX, intervalY, intervalZ; // in frames
  
  public SineSource()
  {
    this(new Position());
  }
  
  public SineSource(Position p)
  {
    super(p);
    int minRandom = 5;
    int maxRandom = 500;
    intervalX = (int)random(minRandom, maxRandom);
    intervalY = (int)random(minRandom, maxRandom);
    intervalZ = (int)random(minRandom, maxRandom);
  }
  
  public void updatePosition()
  {
    position.x = computeNewValue(intervalX, position.startX, width/2);
    position.y = computeNewValue(intervalY, position.startY, height/2);
    position.z = computeNewValue(intervalZ, position.startZ, width/2);
  }
  
  protected float computeNewValue(int interval, float startValue, float maxValue)
  {
    final int frames = frameCount;
    
    final float rem = frames % interval;
    final float percent = rem/(float)(interval);
    final float rad = (float)((2.0 * Math.PI) * percent);
    
    final double s = sin(rad);
    final float newValue = (float)(startValue + (s * maxValue/2));
    return newValue;
  }
}


// a source that pulses the color
public class PulseSource extends SineSource
{
  
  final public int pulseInterval;
  final public color startColor;
  
  public PulseSource()
  {
    super(); 
    pulseInterval = (int)(random(50,500));
    startColor = c;
  }
  
  public void updateColor()
  {
    final int frames = frameCount;
    
    final float rem = frames % pulseInterval;
    final float percent = rem/(float)(pulseInterval);
    final float rad = (float)((2.0 * Math.PI) * percent);
    
    final double s = abs(sin(rad));
    
    int scaledR = (int)(red(startColor) * s);
    int scaledG = (int)(green(startColor) * s);
    int scaledB = (int)(blue(startColor) * s);
    c = color(scaledR, scaledG, scaledB);
  }
}
