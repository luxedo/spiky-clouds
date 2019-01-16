PImage img;
float MIN_LENGTH = 0.0;
float MAX_LENGTH = 0.02;
float MAX_WIDTH = 0.001;
float MIN_WIDTH = 0.0005;
int ALPHA = 255;
String ROTATION = "min_gradient";  // rot mode: min_gradient || max_gradient || random
float[] ANGLES = null;
int RADIUS = 5;
Args parsed;

void settings() {
  int RESIZE = 1;
  if (args == null || args.length < 2) {
    println("You must pass two arguments: [OPTS] INPUT_FILE OUTPUT_FILE");
    println("Opts: -seed, -min-length, -max-length, -min-width, -max-width, -alpha, -rotation, -angles (integer array in degrees)");
    System.exit(1);
  }
  try {
    parsed = new Args(args);
  } catch (Exception e) {
    println(e);
    System.exit(1);
  }
  if (parsed.seed != -1) {
    randomSeed(parsed.seed);
  }
  img = loadImage(parsed.inputFile);
  img.resize(img.width/RESIZE, img.height/RESIZE);
  size(img.width, img.height);
}

void setup() {
  int perimeter = 2*(img.width+img.height);

  ArrayList<Integer> choices = new ArrayList<Integer>();
  for (int i=0; i<img.width*img.height; i++) {
    choices.add(i);
  }
  
  for (int i=0; i<img.width*img.height; i++) {
    int choice = floor(random(1)*choices.size());
    int value = choices.remove(choice);

    int x = value%img.width;
    int y = floor(value/img.width);
    int px = img.get(x, y);

    if (i%Math.floor(img.width*img.height/100) == 0) {
      println(round(float(i)/img.width/img.height*100));
    }

    float length = random(1)*(parsed.maxLength-parsed.minLength)*perimeter + parsed.minLength;
    float width = random(1)*(parsed.maxWidth-parsed.minWidth)*perimeter + parsed.minWidth;
    float rot = getRotation(x, y);
    
    if (parsed.angles != null && parsed.angles.length > 0) {
      rot = collapseAngle(rot, parsed.angles);
    }
    
    float x1 = x + length*sin(rot);
    float y1 = y + length*cos(rot);

    stroke(red(px), green(px), blue(px), parsed.alpha);
    strokeWeight(width);
    line(x, y, x1, y1);
  }
  saveFrame(parsed.outputFile);
  exit();
}

float minimumGradient(PImage img, int x, int y, int radius) {
  // Returns the orientation with the smallest gradient in a radius
  int px = img.get(x, y);
  float min = 1e30;
  ArrayList<int[]> equal = new ArrayList();
  for (int i=-radius; i<=radius; i++) {
    for (int j=-radius; j<=radius; j++) {
      if (i == 0 && j ==0) continue;
      int val = abs(img.get(x+i, y+j) - px);
      float grad = sqrt(sq(red(val)) + sq(green(val)) + sq(blue(val)))/sqrt(sq(i)+sq(j));
      if (grad < min) {
        min = grad;
        int[] data = {i, j};
        equal.clear();
        equal.add(data);
      } else if (grad == min) {
        int[] data = {i, j};
        equal.add(data);
      }
    }
  }
  int index = floor(random(1)*equal.size());  // Gets random when mutiple directions matches
  int gx = equal.get(index)[0];
  int gy = equal.get(index)[1];
  return atan2(gx, gy);
}

float maximumGradient(PImage img, int x, int y, int radius) {
  // Returns the orientation with the maximum gradient in a radius
  int px = img.get(x, y);
  float max = 0;
  ArrayList<int[]> equal = new ArrayList();
  for (int i=-radius; i<=radius; i++) {
    for (int j=-radius; j<=radius; j++) {
      if (i == 0 && j ==0) continue;
      int val = abs(img.get(x+i, y+j) - px);
      float grad = sqrt(sq(red(val)) + sq(green(val)) + sq(blue(val)))/sqrt(sq(i)+sq(j));
      if (grad > max) {
        max = grad;
        int[] data = {i, j};
        equal.clear();
        equal.add(data);
      } else if (grad == max) {
        int[] data = {i, j};
        equal.add(data);
      }
    }
  }
  int index = floor(random(1)*equal.size());  // Gets random when mutiple directions matches
  int gx = equal.get(index)[0];
  int gy = equal.get(index)[1];
  return atan2(gx, gy);
}

float getRotation(int x, int y) {
  switch(parsed.rotation) {
      case("min_gradient"):
        return minimumGradient(img, x, y, RADIUS);
      case("max_gradient"):
        return maximumGradient(img, x, y, RADIUS);
      case("random"):
      default:
        return random(1)*2*PI;
    }
}

float collapseAngle(float rot, float[] angles) {
  float best = Integer.MAX_VALUE;
  float bestDelta = Integer.MAX_VALUE;
  float x = cos(rot);
  float y = sin(rot);
  for (int i=0; i<angles.length; i++) {
    float x0 = cos(angles[i]);
    float y0 = sin(angles[i]);
    float delta = sq(x-x0) + sq(y-y0);
    if (delta < bestDelta) {
      bestDelta = delta;
      best = angles[i];
    }
  }
  return best;
}

class Args {
  int seed = -1; 
  float minLength = MIN_LENGTH; 
  float maxLength = MAX_LENGTH; 
  float minWidth = MIN_WIDTH; 
  float maxWidth = MAX_WIDTH; 
  int alpha = ALPHA; 
  String rotation = ROTATION; 
  float[] angles = ANGLES;
  String inputFile;
  String outputFile;
  Args(String[] args) throws Exception {
    args = reverse(args);
    while (args.length > 0) {
      String arg = trim(args[args.length-1]);
      args = shorten(args);
      if (arg.startsWith("-")) {
        if (args.length == 0) {
          throw new Exception("Missing argument value");
        }
        String val = trim(args[args.length-1]);
        args = shorten(args);
        switch(arg) {
          case "-seed":
            seed = parseInt(val);
            break;
          case "-min-length":
            minLength = parseFloat(val);
            break;
          case "-max-length":
            maxLength = parseFloat(val);
            break;
          case "-min-width":
            minWidth = parseFloat(val);
            break;
          case "-max-width":
            maxWidth = parseFloat(val);
            break;
          case "-alpha":
            alpha = parseInt(val);
            break;
          case "-rotation":
            if (val.equals("min_gradient") || val.equals("max_gradient") || val.equals("random")) {
              rotation = val;
            } else {
              throw new Exception("-rotation must be one of: min_gradient, max_gradient, random");
            }
            break;
          case "-angles":
            String[] _angles = val.split(",");
            angles = new float[0];
            for (int i=0; i<_angles.length; i++) {
              int angleDegree = parseInt(trim(_angles[i]));
              while (angleDegree<0) {
                angleDegree += 360;
              }
              angles = append(angles, angleDegree*PI/180 + PI/2);
            }
            break;
          default:
            throw new Exception("Unrecognized argument");
        }
      } else {
        if (inputFile == null) inputFile = arg;
        else if (outputFile == null) outputFile = arg;
        else throw new Exception("Too many arguments");
      }
    }
    if (inputFile == null || outputFile == null) throw new Exception("Missing arguments");
    if (!inputFile.startsWith("/")) inputFile = "../../"+inputFile;
    if (!outputFile.startsWith("/")) outputFile = "../../"+outputFile;
  }
}
