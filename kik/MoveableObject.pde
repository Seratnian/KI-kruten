class MoveableObject extends SteadyObject
{
  float speed = 10;
  int moveForward = 0;
  int moveRight = 0;
  private float size = LEVEL_UNIT/4;
  float hitSize = LEVEL_UNIT/4;
  float maxAnglePerSecond = HALF_PI; 
  boolean wantsToShoot = false;
  int lastShot = 0;
  int shootPause = 100;
  int lifePoints = 1;
  PVector hitAreaTranslate = new PVector();
  boolean remove = false;
  
  MoveableObject(PVector position, float scale, PVector rotations)
  {
    super(position, scale, rotations);
  }
  MoveableObject(PVector position, float scale, PVector rotations, PShape structure, float size, color plainColor)
  {
    super(position, scale, rotations, structure, plainColor);
    this.size = size;
  }
  
  float getSize() { return size; }
  void setSize(float size) { this.size = size; }
  
  boolean isMoving() { return moveForward != 0 || moveRight != 0; }
  boolean isMovingForward() { return moveForward == 1; }
  boolean isMovingBackward() { return moveForward == -1; }
  boolean isMovingRight() { return moveRight == 1; }
  boolean isMovingLeft() { return moveRight == -1; }
  
  void startMovingForward() { moveForward = 1; }
  void startMovingBackward() { moveForward = -1; }
  void startMovingRight() { moveRight = 1; }
  void startMovingLeft() { moveRight = -1; }
   
  void stopMovingForward() { if (isMovingForward()) moveForward = 0; }
  void stopMovingBackward() { if (isMovingBackward()) moveForward = 0; }
  void stopMovingRight() { if (isMovingRight()) moveRight = 0; }
  void stopMovingLeft() { if (isMovingLeft()) moveRight = 0; }
  
  PVector getHitPosition()
  {
    PVector hitPosition = hitAreaTranslate;
    PVector rotatePlain = new PVector(hitPosition.x, hitPosition.z).rotate(-getRotations().y);
    return getPosition().copy().add(rotatePlain.x, hitPosition.y, rotatePlain.y);
  }
  
  void display()
  {
    //refreshStructure(); // too slow
    super.display();
    /* show HitAreas 
    PShape ps = createShape(SPHERE, hitSize);
    ps.translate(getHitPosition().x, getHitPosition().y, getHitPosition().z);
    ps.setFill(#ff0000);
    shape(ps);
    */
    /* show MoveAreas
    PShape ps2 = createShape(SPHERE, size);
    ps2.translate(getPosition().x, getPosition().y, getPosition().z);
    ps2.setFill(#ffff00);
    shape(ps2);
    */
  }
  
  PVector getMoveDirectionPlain()
  {
    PVector moveDirection = getPlainDirection().mult(speed * 60 / frameRate);
    float moveAngle = new PVector(moveForward, moveRight).heading();
    moveDirection.rotate(-moveAngle);
    return moveDirection;
  }
  
  boolean checkMove(PVector currentPosition, PVector direction)
  {
    return checkMove(currentPosition, direction, true);
  }
  
  boolean checkMove(PVector currentPosition, PVector direction, boolean checkFourPositions)
  {
    boolean isPossible = false;
    PVector dir3d = new PVector(direction.x, 0, direction.y);
    PVector newPosition = currentPosition.copy().add(dir3d);
    if (checkFourPositions)
    {
      PVector dirRotatedClock = direction.copy().normalize().mult(size).rotate(PI/8);
      PVector dirRotatedCounter = dirRotatedClock.copy().rotate(-PI/4);
      PVector[] toTest =
      {
        newPosition,
        newPosition.copy().add(dir3d.normalize().mult(size)),
        newPosition.copy().add(dirRotatedClock.x, 0, dirRotatedClock.y),
        newPosition.copy().add(dirRotatedCounter.x, 0, dirRotatedCounter.y)
      };
      int i = 0;
      if (isPositionFree(toTest[i++]) && isPositionFree(toTest[i++]) && isPositionFree(toTest[i++]) && isPositionFree(toTest[i]))
      {
        isPossible = true;
      }
    }
    else
    {
      isPossible = isPositionFree(newPosition);
    }
    return isPossible;
  }
  
  PVector getPlainDirection()
  {
    return new PVector(1, 0).rotate(-getRotations().y);
  }
  PVector get3dDirection()
  {
    PVector direction = new PVector(1, 0, 0);
    rotateY(direction, -getRotations().y);
    rotateZ(direction, -getRotations().z);
    rotateX(direction, -getRotations().x);
    return direction;
  }
  PVector getMoveDirection3d()
  {
    return getRotations().copy().normalize().mult(speed);
  }
  
  void movePlain(PVector direction)
  {
    move3d(new PVector(direction.x, 0, direction.y));
  }
  
  void move3d(PVector direction)
  {
    PVector position = getPosition();
    position.x += direction.x;
    position.y += direction.y;
    position.z += direction.z;
    if (structure != null) 
    {
      structure.translate(direction.x, direction.y, direction.z);
    }
  }
  
  void rotatePlain(float angle)
  {
    getRotations().add(0, angle, 0);
    if (structure != null)
    {
      PVector translation = getPosition();
      structure.translate(-translation.x, -translation.y, -translation.z);
      structure.rotateY(angle);
      structure.translate(translation.x, translation.y, translation.z);
    }
  }
  
  void shoot()
  {
    wantsToShoot = true;
  }
  
  boolean update()
  {
    // if the MoveableObject also is a ShootingObject, perform the shooting routine 
    try
    {
      ShootingObject shooter = (ShootingObject) this;
      if (wantsToShoot && millis() - lastShot > shootPause)
      {
        shooter.performShot();
        wantsToShoot = false;
        lastShot = millis();
      }
    }
    catch (Exception e) { }
    return !remove;
  }
  
  boolean checkCollision(MoveableObject mo)
  {
    return mo.getHitPosition().dist(getHitPosition()) <= mo.hitSize + hitSize;
  }
  
  void doDamage(int damage)
  {
    lifePoints -= damage;
    if (lifePoints <= 0)
    {
      destroy();
    }
  }
  
  void destroy()
  {
    remove = true;
  }
}