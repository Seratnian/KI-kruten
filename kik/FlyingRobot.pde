class FlyingRobot extends KIObject implements ShootingObject
{ 
  color bulletColor = #000000;
  final float BULLET_SPEED = 100;
  final static float SHOOTING_ANGLE = -PI/16;
  private PVector lastEnemySpottedPosition;
  private float lastEnemySpottedTime;
  
  FlyingRobot(PVector position, PVector rotations, color plainColor, Strategy strategy)
  {
    super(position.add(0, LEVEL_HEIGHT/4, 0), 1, rotations, loadShape(MODELS + "robot/robot.obj"), LEVEL_UNIT/3, plainColor, strategy);
    hitAreaTranslate.y = LEVEL_UNIT/10;
    hitAreaTranslate.x = LEVEL_UNIT/16;
    bulletColor = plainColor;
    hitSize = getSize() / 2;
  }
  
  // shoots
  void performShot()
  {
    Projectile projectile = new Projectile(getWeaponPosition(), get3dDirection().add(0, SHOOTING_ANGLE, 0), createShape(SPHERE, .01 * LEVEL_UNIT), .01 * LEVEL_UNIT, bulletColor, BULLET_SPEED);
    projectiles.add(projectile);
  }
  
  PVector getWeaponPosition()
  {
    return getActionPosition();
  }
  
  void rotateTowardsEnemy(PVector enemyPosition)
  {
      PVector toEnemy = enemyPosition.sub(getPosition()).normalize();
      PVector toFront = getPlainDirection().copy().normalize();
      
      float rotationDirection = - Math.min(1, Math.max(-1, toFront.x * toEnemy.z - toFront.y * toEnemy.x));
      //message("Found an enemy. Rotating " + (rotationDirection > 0 ? "right" : "left"));
      rotatePlain(maxAnglePerSecond / frameRate * rotationDirection);
  }
  
  boolean update()
  {
    // here comes the logic of the KI
    switch (strategy)
    {
      case DO_NOTHING:
      default:
        break;
      case LOOK_FOR_OPPONENTS:
        HashMap<PVector, Visual> visuals = performLooks(get3dDirection().add(0, SHOOTING_ANGLE, 0), LookDirection.FORWARD_22_45_67_AND_90);
        boolean foundEnemy = false;
        for (PVector enemyPosition : visuals.keySet())
        {
          if (visuals.get(enemyPosition) != Visual.WALL)
          {
            lastEnemySpottedPosition = enemyPosition.copy();
            lastEnemySpottedTime = millis();
            // determine the direction of the rotation
            // if the last enemy spotting happened recently, don't forget it
            if (millis() - lastEnemySpottedTime < 1000)
              enemyPosition.mult(2).add(lastEnemySpottedPosition).div(3);

            rotateTowardsEnemy(enemyPosition);
            
            shoot();
            break;
          }
        }
        if (millis() - lastEnemySpottedTime < 1000)
        {
          rotateTowardsEnemy(lastEnemySpottedPosition);
          shoot();
          break;
        }
      case ALWAYS_MOVE_AND_SHOOT:
        if (!isMoving())
        {
          startMovingForward();
        }
        if (isMoving())
        {
          if (checkMove(getPosition(), getPlainDirection()))
          {
            movePlain(getMoveDirectionPlain());
          }
          else
          {
            rotatePlain(maxAnglePerSecond / frameRate * preferredRotatedirection);
          }
        }
        // roll the direction of rotation every 5 seconds
        if (second() % 5 == 0) preferredRotatedirection = randomSign();
        
        // try to shoot
        shoot();
        break;
    }
    return super.update();
  }
}