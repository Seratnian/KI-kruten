import java.util.Collections;

class Data
{
  // the UI
  private final ArrayList<UIObject> ui = new ArrayList<UIObject>();
  ArrayList<UIObject> getUi() { 
    return ui;
  }
  private PImage crosshair = loadImage(IMAGES + "crosshair.png");
  private PImage pistol = loadImage(IMAGES + "pistol.png");
  
  // The unlively part of the game
  PShape environment = createShape(GROUP);
  PShape getEnvironment() { return environment; }
  
  PImage wall = loadImage(TEXTURES + "wall.jpg");
  PImage floor = loadImage(TEXTURES + "floor.jpg");
  PImage ceiling = loadImage(TEXTURES + "ceiling.jpg");
  private final boolean[][] walls = {
    //  0      1      2       3      4      5     6      7       8      9     10     11     12     13     14     15    16      17     18     19
    { false, false, false, false, false, false, true, false, false, true, false, false, false, true, false, false, false, false, false, true  }, // 0
    { false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, true  }, // 1
    { false, false, true, true, false, false, false, false, false, true, false, false, false, false, false, false, true, false, false, true  }, // 2
    { false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, false }, // 3
    { false, false, false, false, false, false, false, false, false, false, false, true, true, true, false, false, true, false, false, false }, // 4
    { false, false, false, false, false, false, false, true, true, true, false, false, false, false, false, false, true, false, false, false }, // 5
    { true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, false, false, true  }, // 6
    { false, false, false, false, false, true, false, false, false, false, false, false, false, true, false, false, false, false, false, true  }, // 7
    { false, false, false, false, false, true, false, false, false, false, true, false, false, false, false, false, false, true, true, true  }, // 8
    { true, true, true, false, false, true, false, false, false, false, true, false, false, false, false, false, false, false, false, false }, // 9
    { false, false, false, false, false, false, false, false, true, true, true, false, false, true, true, true, true, false, false, false }, // 10
    { false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }, // 11
    { false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true  }, // 12
    { true, false, false, false, true, false, false, true, false, false, true, false, false, true, true, false, false, false, false, true  }, // 13
    { false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, false, false, true, false, true  }, // 14
    { false, false, false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, true, false, false }, // 15
    { false, false, true, true, true, true, true, false, false, false, true, false, false, false, false, false, false, false, false, false }, // 16
    { false, false, false, false, false, false, false, false, true, false, false, false, false, false, true, true, false, false, false, true  }, // 17
    { false, false, false, false, false, false, false, false, true, false, false, false, false, false, false, false, false, false, false, false }  // 18
  };                                                                                                                                        //m

  // enemies
  private final ArrayList<MoveableObject> enemies = new ArrayList<MoveableObject>();
  ArrayList<MoveableObject> getEnemies() { return enemies; }
  
  // start positions
  private final ArrayList<PVector> startPositions = new ArrayList<PVector>();
  ArrayList<PVector> getStartPositions() { return startPositions; }

  Data()
  {
    //insert the border objects
    environment.addChild(new SteadyObject(new PVector(), 1, new PVector(), createShape(BOX, LEVEL_WIDTH, 1, LEVEL_WIDTH), floor).getStructure()); //floor
    environment.addChild(new SteadyObject(new PVector(LEVEL_WIDTH/2, LEVEL_HEIGHT/2, 0), 1, new PVector(), createShape(BOX, 1, LEVEL_HEIGHT, LEVEL_WIDTH), wall).getStructure()); //wall 1
    environment.addChild(new SteadyObject(new PVector(-LEVEL_WIDTH/2, LEVEL_HEIGHT/2, 0), 1, new PVector(), createShape(BOX, 1, LEVEL_HEIGHT, LEVEL_WIDTH), wall).getStructure()); //wall 2
    environment.addChild(new SteadyObject(new PVector(0, LEVEL_HEIGHT/2, LEVEL_WIDTH/2), 1, new PVector(), createShape(BOX, LEVEL_WIDTH, LEVEL_HEIGHT, 1), wall).getStructure()); //wall 3
    environment.addChild(new SteadyObject(new PVector(0, LEVEL_HEIGHT/2, -LEVEL_WIDTH/2), 1, new PVector(), createShape(BOX, LEVEL_WIDTH, LEVEL_HEIGHT, 1), wall).getStructure()); //wall 4
    environment.addChild(new SteadyObject(new PVector(0, LEVEL_HEIGHT, 0), 1, new PVector(), createShape(BOX, LEVEL_WIDTH, 1, LEVEL_WIDTH), ceiling).getStructure()); //ceiling

    for (int r = walls.length - 1; r >= 0; r--)
    {
      boolean[] row = walls[r];
      for (int c = row.length - 1; c >= 0; c--)
      {
        boolean cell = row[c];
        if (cell)
        {
          environment.addChild(new SteadyObject(new PVector((walls.length - r) * LEVEL_UNIT, LEVEL_HEIGHT/2, (row.length - c - 1) * LEVEL_UNIT), 1, new PVector(), createShape(BOX, LEVEL_UNIT, LEVEL_HEIGHT, LEVEL_UNIT), wall).getStructure());
          environment.addChild(new SteadyObject(new PVector((row.length - c - 1) * LEVEL_UNIT, LEVEL_HEIGHT/2, (walls.length - r) * -LEVEL_UNIT), 1, new PVector(), createShape(BOX, LEVEL_UNIT, LEVEL_HEIGHT, LEVEL_UNIT), wall).getStructure());
          environment.addChild(new SteadyObject(new PVector((row.length - c - 1) * -LEVEL_UNIT, LEVEL_HEIGHT/2, (walls.length - r) * LEVEL_UNIT), 1, new PVector(), createShape(BOX, LEVEL_UNIT, LEVEL_HEIGHT, LEVEL_UNIT), wall).getStructure());
          environment.addChild(new SteadyObject(new PVector((walls.length - r) * -LEVEL_UNIT, LEVEL_HEIGHT/2, (row.length - c - 1) * -LEVEL_UNIT), 1, new PVector(), createShape(BOX, LEVEL_UNIT, LEVEL_HEIGHT, LEVEL_UNIT), wall).getStructure());
        }
      }
    }

    ui.add(new UIObject(new PVector(width/2 - crosshair.width/2, height/2 - crosshair.height/2), 1, new PVector(), crosshair));
    ui.add(new UIObject(new PVector(20, 20), 1, new PVector(), UIObject.METHOD_FPS));
    ui.add(new UIObject(new PVector(width/2 - pistol.width/8, height - pistol.height), 1, new PVector(), pistol));
    
    // add start positions
    int distance = LEVEL_SIZE_HALF * LEVEL_UNIT;
    
    //startPositions.add(new PVector(distance, 0, distance));
    //startPositions.add(new PVector(-distance, 0, distance));
    //startPositions.add(new PVector(distance, 0, -distance));
    //startPositions.add(new PVector(-distance, 0, -distance));
    
    startPositions.add(new PVector(LEVEL_UNIT/2, 0, LEVEL_UNIT/2));
    startPositions.add(new PVector(-LEVEL_UNIT/2, 0, LEVEL_UNIT/2));
    startPositions.add(new PVector(LEVEL_UNIT/2, 0, -LEVEL_UNIT/2));
    startPositions.add(new PVector(-LEVEL_UNIT/2, 0, -LEVEL_UNIT/2));
    
    Collections.shuffle(startPositions);
    
    // add enemies
    //enemies.add(new FlyingRobot(startPositions.get(1), new PVector(0, random(-PI, PI), 0), #996666, Strategy.LOOK_FOR_OPPONENTS));
    //enemies.add(new FlyingRobot(startPositions.get(2), new PVector(0, random(-PI, PI), 0), #669966, Strategy.LOOK_FOR_OPPONENTS));
    enemies.add(new FlyingRobot(startPositions.get(3), new PVector(0, random(-PI, PI), 0), #666699, Strategy.LOOK_FOR_OPPONENTS));
    
    // set player's start position
    PVector position = player.getPosition();
    position.set(startPositions.get(0).x, position.y, startPositions.get(0).z);
  }

  boolean[][] getWalls()
  {
    return walls;
  }

}