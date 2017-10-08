/** //<>//
 * Simulation for a 3D first person shooter
 *
 * @author sschleie@hs-mittweida.de
 */

import java.awt.Robot;
import java.awt.AWTException;

final boolean debugMode = false;
static Level level = Level.TRAIN_EXISTING;
final int SUCCESS_NEEDED = 100;

final String NETWORK_JSON = "networks.json";
final String NETWORK_EXISTING_JSON = "networks_to_train.json";
static int LEVEL_SIZE;
static int LEVEL_SIZE_HALF;
static int LEVEL_WIDTH;
static int LEVEL_UNIT = 250;
static int LEVEL_HEIGHT = LEVEL_UNIT * 4;
static int TIME_TO_PLAY;
final int SUCCESS_FOR_LOOKING = 2;
final int SUCCESS_FOR_SHOOTING = 5;
final int SUCCESS_FOR_DESTROYING = 100;
final int SUCCESS_FOR_WINNING = 500;

final int LINE_HEIGHT = 20;
final String MODELS = "models/";
final String TEXTURES = "textures/";
final String IMAGES = "images/";

final int BG_COLOR = #111133;
int wHalf, hHalf;
int currentLine = 2;
int messages_destroyed = 0;
int startTime;
JSONArray jsonNetworks = new JSONArray();
JSONArray jsonRemainingNetworks;

// loading data
Data data;
// level description
PShape environment;
// user interface
ArrayList<UIObject> ui;
// enemies
ArrayList<MoveableObject> enemies;
// projectiles
ArrayList<Projectile> projectiles = new ArrayList<Projectile>();

ArrayList<Ray> rays = new ArrayList();

final Camera camera = new Camera();

final Player player = new Player(new PVector(), 1, new PVector(PI, 0, 0));

Robot robot;

void setup()
{
  fullScreen(P3D);
  //size(800, 800, P3D);
  wHalf = width/2;
  hHalf = height/2;
  noCursor();

  try
  { 
    robot = new Robot();
  } 
  catch (AWTException e)
  {
    e.printStackTrace();
  }
  robot.mouseMove(wHalf, hHalf);

  if (level == Level.TRAIN_EXISTING)
  {
    jsonRemainingNetworks = loadJSONArray(NETWORK_EXISTING_JSON);
    println (jsonRemainingNetworks.size() + "");
    if (jsonRemainingNetworks.size() < 4)
    {
      println("there are too few networks to train with.");
      exit();
      return;
    }
    for (int i = 0; i < 4; i++)
    {
      jsonNetworks.append( (JSONObject) jsonRemainingNetworks.remove(0));
    }
  }
  data = new Data();
  environment = data.getEnvironment();
  ui = data.getUi();
  enemies = data.getEnemies();
  
  startTime = millis();
}

void draw()
{
  // clear screen
  background(BG_COLOR);
  lights();
  textureWrap(REPEAT);

  if (millis() - startTime > TIME_TO_PLAY * 1000)
  {
    endGame();
  }
  player.update();

  // Recalculate Rotation
  // get current mouse position relative to middle of screen
  float xRotation = (float)(mouseX - wHalf) / width * -4 * PI;
  float yRotation = (float)(mouseY - hHalf) / height * 4 * PI;
  PVector mouse = new PVector(xRotation, yRotation);
  // rotate the camera
  camera.rotate(mouse);
  // reset mouse position to the screen center
  if (focused)
    robot.mouseMove(wHalf, hHalf);

  camera(camera.getEyeX(), camera.getEyeY(), camera.getEyeZ(), 
    camera.getCenterX(), camera.getCenterY(), camera.getCenterZ(), 
    camera.getUpX(), camera.getUpY(), camera.getUpZ());

  shape(environment);

  for (int i = enemies.size() - 1; i >= 0; i--)
  {
    MoveableObject mo = enemies.get(i);
    if (!mo.update())
    {
      enemies.remove(i);
      continue;
    }
    mo.display();
  }
  noLights();
  for (Ray ray : rays)
  {
    ray.draw();
  }
  if (second() % 5 == 0)
    rays.clear();
  for (int i = projectiles.size() - 1; i >= 0; i--)
  {
    Projectile pr = projectiles.get(i);
    if (!pr.update())
    {
      projectiles.remove(i);
      continue;
    }
    pr.display();
  }
  camera();
  hint(DISABLE_DEPTH_TEST);
  for (int i = ui.size() - 1; i >= 0; i--)
  {
    UIObject uo = ui.get(i);
    if (!uo.update())
    {
      ui.remove(i);
      messages_destroyed++;
      continue;
    }
    uo.display();
  }
  hint(ENABLE_DEPTH_TEST);
}

int[] getCoordsFromPosition(PVector position)
{
  int x = round(position.x / LEVEL_UNIT);
  int z = round(position.z / LEVEL_UNIT);
  int[] coords = {LEVEL_SIZE_HALF - abs(x), LEVEL_SIZE_HALF - abs(z)};
  // The level description only contains a quarter of the level, so it is nesseccary to map the coordinates to all four parts.
  if (x == 0 || (x < 0 && z > 0) || (z < 0 && x > 0))
  {
    coords[0] = LEVEL_SIZE_HALF - abs(z);
    coords[1] = LEVEL_SIZE_HALF - abs(x);
  }
  return coords;
}

boolean isPositionFree(PVector position)
{
  int[] coords = getCoordsFromPosition(position);
  if (coords[0] == LEVEL_SIZE_HALF && coords[1] == LEVEL_SIZE_HALF) return true; // The middle of the level always is free.
  boolean isFree;
  try
  {
    isFree = !data.getWalls()[coords[0]][coords[1]];
  }
  catch (IndexOutOfBoundsException e)
  {
    isFree = false;
  }
  if (debugMode)
  {
    PShape ps = createShape(BOX, 10);
    ps.translate(position.x + camera.getCenter().x * 100, camera.getEyeY(), position.z + camera.getCenter().z * 100);
    ps.setFill(#ffffff);
    shape(ps);
    println(position.x + ", " + position.z + " is free.");
  }
  return isFree;
}

void mousePressed()
{
  if (mouseButton == LEFT)
  {
    // the player wants to shoot
    player.shoot();
  }
}

void keyPressed()
{
  switch (key)
  {
    // the player wants to move
  case 'w':
    player.startMovingForward();
    break;
  case 's':
    player.startMovingBackward();
    break;
  case 'a':
    player.startMovingLeft();
    break;
  case 'd':
    player.startMovingRight();
    break;
  case 'p':
    // take screenshot
    save("screenshots/screen_" + day() + "_" + hour() + "_" + minute() + "_" + second() + ".jpg");
    break;
  case 'e':
    // end game and save successful networks
    endGame();
    break;
  }
}
void keyReleased()
{
  switch (key)
  {
    // the player wants to stop moving
  case 'w':
    player.stopMovingForward();
    break;
  case 's':
    player.stopMovingBackward();
    break;
  case 'a':
    player.stopMovingLeft();
    break;
  case 'd':
    player.stopMovingRight();
    break;
  }
}

int randomSign()
{
  return round(random(0, 1)) * 2 - 1;
}

void message(String text)
{
  println(text);
  ui.add(new UIObject(new PVector(20, currentLine++ * LINE_HEIGHT), 1, new PVector(), UIObject.METHOD_DIE, text));
}

PVector rotateX(PVector vector3d, float angle)
{
  PVector vector2d = new PVector(vector3d.y, vector3d.z).rotate(angle);
  vector3d.set(vector3d.x, vector2d.x, vector2d.y);
  return vector3d;
}
PVector rotateY(PVector vector3d, float angle)
{
  PVector vector2d = new PVector(vector3d.x, vector3d.z).rotate(angle);
  vector3d.set(vector2d.x, vector3d.y, vector2d.y);
  return vector3d;
}
PVector rotateZ(PVector vector3d, float angle)
{
  PVector vector2d = new PVector(vector3d.x, vector3d.y).rotate(angle);
  vector3d.set(vector2d.x, vector2d.y, vector3d.z);
  return vector3d;
}

void endGame()
{
  JSONArray networks = loadJSONArray(NETWORK_JSON);
  for (MoveableObject mo : enemies)
  {
    try {
      KIObject kio = (KIObject) mo;
      if (enemies.size() == 0)
        kio.success += SUCCESS_FOR_WINNING;
      message (kio.success + "");
      if (kio.strategy == Strategy.NEURAL_NETWORK && kio.success >= SUCCESS_NEEDED)
      {
        JSONObject network = kio.getNetworkJSON();
        networks.append(network);
      }
    }
    catch (Exception e) {
    }
  }
  saveJSONArray(networks, "data/" + NETWORK_JSON);
  if (level == Level.TRAIN_EXISTING)
    saveJSONArray(jsonRemainingNetworks, "data/" + NETWORK_EXISTING_JSON);
  exit();
}
enum Level
{
  GAME, TRAIN_NEW, TRAIN_EXISTING
}