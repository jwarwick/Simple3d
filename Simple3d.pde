import peasy.*;

PeasyCam cam;

static int SCREEN_WIDTH = 500;
static int SCREEN_HEIGHT = 500;


static int FIXTURE_SIZE = 40;

static int NUM_FIXTURES = 200;
Fixture[] fixtureArray;


static int SOURCE_SIZE = 10;

static int NUM_SOURCES = 5;
Source[] sourceArray;

void setup()
{
  size(SCREEN_WIDTH, SCREEN_HEIGHT, P3D);

  // PeasyCam instructions:  
  // left click and drag to rotate camera
  // right click and drag to zoom
  // double click to reset to initial position
  // splat + left click and drag to pan (or 3rd mouse button and drag)

  cam = new PeasyCam(this, width/2, height/2, width, 500);
  cam.setMinimumDistance(50);
  cam.setMaximumDistance(2000);

  fixtureArray = new Fixture[NUM_FIXTURES];  
  for (int index=0; index<fixtureArray.length; ++index)
  {
    Fixture f = new Fixture(new Position()); 
    fixtureArray[index] = f;
    //println("Fixture at " + f.position.toString());
  }
  
  sourceArray = new Source[NUM_SOURCES];  
  for (int index=0; index<sourceArray.length; ++index)
  {
    Source s = new Source(new Position()); 
    sourceArray[index] = s;
    //println("Source at " + s.position.toString());
  }
  
}

void draw()
{
  computeUpdatedColors();
  
  background(0);
  noStroke();
  ambientLight(255, 255, 255);
  
  for (int i=0; i<sourceArray.length; ++i)
  {
    sourceArray[i].draw();
  }
  
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

void computeUpdatedColors()
{
  for (int i=0; i<NUM_FIXTURES; ++i)
  {
    fixtureArray[i].updateColors(sourceArray);
  }
}


class Position
{
  float x, y, z;

  Position(float xPos, float yPos, float zPos)  
  {
    x = xPos;
    y = yPos;
    z = zPos;
  }

  // generate a random position  
  Position()
  {
     x = random(0, width);
     y = random(0, height);
     z = random(0, height);
  }
  
  String toString()
  {
    return "(" + x + "," + y + "," + z + ")";
  }
  
  void randomMove(float maxRange)
  {
    x = random(x-maxRange, x+maxRange);
    y = random(y-maxRange, y+maxRange);
    z = random(z-maxRange, z+maxRange);
  }
  
  float distanceTo(Position targetPos)
  {
    // manhattan distance, good enough
    float distance = abs(x - targetPos.x);
    distance += abs(y - targetPos.y);
    distance += abs(z - targetPos.z);
    return distance;
  }
}


// object that displays a color
class Fixture
{
  Position position;
  color fixtureColor;
  
  Fixture(float xpos, float ypos, float zpos)
  {
    position = new Position(xpos, ypos, zpos);
  }
  
  Fixture(Position p)
  {
    position = p;
  }
  
  void draw()
  {
    pushMatrix();
    noStroke();
    translate(position.x, position.y, position.z);
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
      color c = sources[i].colorAtPoint(position);
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
    
    fixtureColor = color(r, g, b);
  }
}


// object that generates a color
class Source
{
  Position position;
  float range = 600.0;
  color c = color(random(0, 255), random(0, 255), random(0, 255));
  
  Source(float xpos, float ypos, float zpos)
  {
    position = new Position(xpos, ypos, zpos);
  }
  
  Source(Position p)
  {
    position = p;
  }
  
  void draw()
  {
    pushMatrix();
    noStroke();
    translate(position.x, position.y, position.z);
    fill(c);
    sphere(SOURCE_SIZE);
    popMatrix();
  }
  
  void updatePosition()
  {
    position.randomMove(2);
  }
  
  void updateColor()
  {
    randomColorShift();
  }
  
  void randomColorShift()
  {
    int newR = (int)red(c) + (int)random(-5, 5);
    int newG = (int)green(c) + (int)random(-5, 5);
    int newB = (int)blue(c) + (int)random(-5, 5);
    c = color(newR, newG, newB);
  }
  
  
  color colorAtPoint(Position targetPos)
  {
    float distance = position.distanceTo(targetPos);

    if (distance > range)
    {
      return color(0,0,0);
    }
    
    float percent = distance/range;
    float fallOff = 1.0 - percent;
    fallOff *= fallOff;
 
    int r = (int)(red(c) * fallOff);
    int g = (int)(green(c) * fallOff);
    int b = (int)(blue(c) * fallOff);
    return color(r, g, b);
  }
}

