class KIObject extends MoveableObject implements SeeingObject
{
  final static int ENERGY_START = 200;
  final static int ENERGY_SHOOT = 10;
  final static int ENERGY_LOOK = 1;
  final static int ENERGY_REG = 10;
  
  int energy = ENERGY_START;
  int lastTimeRegenerated;
  Strategy strategy;
  int preferredRotatedirection = randomSign();
  int success = 0;
  Network network;
  
  KIObject(PVector position, float scale, PVector rotations, PShape structure, float size, color plainColor, Strategy strategy)
  {
    super(position, scale, rotations, structure, size, plainColor);
    this.strategy = strategy;
    speed *= random(0.9, 1.1);
  }
  
  // return Coordinates where projectiles are created and rays are casted
  PVector getActionPosition()
  {
    return get3dDirection().add(0, -PI/8, 0).mult(getSize() * 2).add(getPosition());
  }
  
  void performLook(PVector direction, HashMap<PVector, Visual> out)
  {
    if (energy < ENERGY_LOOK)
      return;
    energy -= ENERGY_LOOK;
    Ray ray = new Ray(getActionPosition(), direction);
    //rays.add(ray);
    ray.cast(out);
  }
  
  HashMap<PVector, Visual> performLooks(ArrayList<PVector> directions)
  {
    HashMap<PVector, Visual> visuals = new HashMap();
    
    for (PVector direction : directions)
    {
      performLook(direction, visuals);
    }
    
    return visuals;
  }
  
  HashMap<PVector, Visual> performLooks(PVector baseDirection, LookDirection lookDirection)
  {
    ArrayList<PVector> directions = new ArrayList();
    
    boolean isLookingDirectionX = Math.abs(baseDirection.x) > Math.abs(baseDirection.z);
    
    // calculate all possible perpendiculars
    ArrayList<PVector> perpendiculars = new ArrayList();
    if (true)
    {
      perpendiculars.add(new PVector( baseDirection.z,  baseDirection.y, -baseDirection.x));
      perpendiculars.add(new PVector(-baseDirection.z,  baseDirection.y,  baseDirection.x));
    }
    
    if (isLookingDirectionX)
    {
      perpendiculars.add(new PVector(-baseDirection.y,  baseDirection.x,  baseDirection.z));
      perpendiculars.add(new PVector( baseDirection.y, -baseDirection.x,  baseDirection.z));
    }
    
    if (!isLookingDirectionX)
    {
      perpendiculars.add(new PVector( baseDirection.x,  baseDirection.z, -baseDirection.y));
      perpendiculars.add(new PVector( baseDirection.x, -baseDirection.z,  baseDirection.y));
    }
    
    if (lookDirection.name().indexOf("FORWARD") > -1)
        directions.add(baseDirection);
    if (lookDirection.name().indexOf("22") > -1)
        for (PVector per : perpendiculars)
          directions.add(PVector.add(PVector.mult(per, 1), PVector.mult(baseDirection, 4)).div(5));
    if (lookDirection.name().indexOf("45") > -1)
        for (PVector per : perpendiculars)
          directions.add(PVector.add(per, baseDirection).div(2));
    if (lookDirection.name().indexOf("67") > -1)
        for (PVector per : perpendiculars)
          directions.add(PVector.add(PVector.mult(per, 4), PVector.mult(baseDirection, 1)).div(5));
    if (lookDirection.name().indexOf("90") > -1)
        for (PVector per : perpendiculars)
          directions.add(per.copy());
    
    return performLooks(directions);
  }
  
  boolean update()
  {
    if (lastTimeRegenerated != second())
    {
      energy = Math.min(ENERGY_START, energy + ENERGY_REG);
      lastTimeRegenerated = second();
    }
    
    return super.update();
  }
  
  JSONObject getNetworkJSON()
  {
    return network.getJSON();
  }
}

public enum Strategy
{
  DO_NOTHING, ALWAYS_MOVE_AND_SHOOT, LOOK_FOR_OPPONENTS, NEURAL_NETWORK
}