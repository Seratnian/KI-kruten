class Player extends MoveableObject implements ShootingObject
{
  final color BULLET_COLOR = #000000;
  final float BULLET_SPEED = 100;
  
  Player(PVector position, float scale, PVector rotations)
  {
    super(position, scale, rotations);
    speed = 10;
    setSize(LEVEL_UNIT/2);
  }
  PVector getPosition()
  {
    return camera.getEye();
  }
  PVector getRotations()
  {
    return camera.getDirection();
  }
  PVector getWeaponPosition()
  {
    return camera.getDirection().copy().normalize().mult(getSize() * 2).add(camera.getEye());
  }
  boolean update()
  {
    // if necessary and possible, move
    if (isMoving() && checkMove(getPosition(), getMoveDirectionPlain()))
    {
      movePlain(getMoveDirectionPlain());
    }
    return super.update();
  }
  
  PVector getPlainDirection()
  {
    return camera.getPlainDirection();
  }
  
  void performShot()
  {
    Projectile projectile = new Projectile(this, getWeaponPosition(), getRotations(), createShape(SPHERE, .01 * LEVEL_UNIT), .01 * LEVEL_UNIT, BULLET_COLOR, BULLET_SPEED);
    projectiles.add(projectile);
  }
  void reportHit() { }
}