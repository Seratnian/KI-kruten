class Ray extends MoveableObject
{
  private final static float SIZE = .1f;
  private final static float SPEED = 10;
  PVector start;
  PVector end;
  
  Ray(PVector position, PVector rotation)
  {
    super(position, 1, rotation);
    setSize(SIZE);
    speed = SPEED;
    start = getPosition().copy();
    end = getPosition().copy();
  }
  
  void cast(HashMap<PVector, Visual> out)
  {
    while (checkMove(getPosition(), new PVector(1, 0, 0), false))
    {
      move3d(getMoveDirection3d());
      for (MoveableObject mo : enemies)
      {
        if (checkCollision(mo))
        {
          out.put(mo.getPosition().copy(), Visual.ROBOT);
          end = getPosition().copy();
          return;
        }
      }
      // ignore the player in training mode
      if (level != Level.TRAIN_NEW && level != Level.TRAIN_EXISTING && checkCollision(player))
      {
        out.put(player.getPosition().copy(), Visual.PLAYER);
        end = getPosition().copy();
        return;
      }
    }
    
    end = getPosition().copy();
    out.put(getPosition().copy(), Visual.WALL);
  }
  
  void draw()
  {
    line(start.x, start.y, start.z, end.x, end.y, end.z); 
  }
}