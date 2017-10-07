class FlyingRobot extends KIObject implements ShootingObject
{ 
  color bulletColor = #000000;
  final float BULLET_SPEED = 100;
  final static float SHOOTING_ANGLE_DEFAULT = -PI/8;
  final static float SHOOTING_ANGLE_PLAYER = -PI/16;
  final static float SHOOTING_ANGLE_ROBOT = -PI/2;
  final static float LOOK_DIRECTION_RANGE = .2f;
  float shootingAngle = SHOOTING_ANGLE_DEFAULT;
  private PVector lastEnemySpottedPosition;
  private Visual lastEnemySpottedType = Visual.WALL;
  private float lastEnemySpottedTime;
  private Network network;
  
  FlyingRobot(PVector position, PVector rotations, color plainColor, Strategy strategy)
  {
    super(position.add(0, LEVEL_HEIGHT/4, 0), 1, rotations, loadShape(MODELS + "robot/robot.obj"), LEVEL_UNIT/3, plainColor, strategy);
    hitAreaTranslate.y = LEVEL_UNIT/10;
    hitAreaTranslate.x = LEVEL_UNIT/16;
    bulletColor = plainColor;
    hitSize = getSize() / 2;
  }
  
  FlyingRobot(PVector position, PVector rotations, color plainColor, Network network)
  {
    this(position, rotations, plainColor, Strategy.NEURAL_NETWORK);
    this.network = network;
  }
  
  private float getEnemyTimeFactor()
  {
    return 100 / (millis() - lastEnemySpottedTime);
  }
  
  // shoots
  void performShot()
  {
    if (energy < ENERGY_SHOOT)
      return;
    energy -= ENERGY_SHOOT;
    message("shot. new energy level " + energy);
    Projectile projectile = new Projectile(getWeaponPosition(), get3dDirection().add(0, shootingAngle, 0), createShape(SPHERE, .01 * LEVEL_UNIT), .01 * LEVEL_UNIT, bulletColor, BULLET_SPEED);
    projectiles.add(projectile);
  }
  
  PVector getWeaponPosition()
  {
    return getActionPosition();
  }
  
  float scalarProduct(PVector a, PVector b)
  {
    return Math.min(1, Math.max(-1, a.x * b.z - a.y * b.x));
  }
  
  float scalarProductFromPosition(PVector otherVector)
  {
    return scalarProduct(otherVector.sub(getPosition()).normalize(), getPlainDirection().copy().normalize());
  }
  
  void rotateTowardsEnemy(PVector enemyPosition)
  {
      // determine the direction of the rotation
      float rotationDirection = - scalarProductFromPosition(enemyPosition);
      //message("Found an enemy. Rotating " + (rotationDirection > 0 ? "right" : "left"));
      // apply rotation
      rotatePlain(maxAnglePerSecond / frameRate * rotationDirection);
  }
  
  void adjustWeaponSystem(Visual visual)
  {
    float targetedShootingAngle;
    switch (visual)
    {
      case PLAYER: targetedShootingAngle = SHOOTING_ANGLE_PLAYER; break;
      case ROBOT: targetedShootingAngle = SHOOTING_ANGLE_ROBOT; break;
      default: targetedShootingAngle = SHOOTING_ANGLE_DEFAULT;
    }
    shootingAngle = (shootingAngle + targetedShootingAngle) / 2;
  }
  
  void saveEnemySpotting(Visual type, PVector position)
  {
    lastEnemySpottedPosition = position.copy();
    lastEnemySpottedType = type;
    lastEnemySpottedTime = millis();
  }
  
  float shiftToPossibleNegativity(float value)
  {
    return value * 2 - 1;
  }
  
  boolean update()
  {
    // here comes the logic of the KI
    switch (strategy)
    {
      case DO_NOTHING:
      default:
        break;
      case NEURAL_NETWORK:
        
        // recalculate the network
        network.resolve();
        
        // check the outputs
        // move
        if (checkMove(getPosition(), getPlainDirection()))
        {
          movePlain(getMoveDirectionPlain().mult(network.getOutput(NeuronName.MOVE)));
        }
        // rotate
        rotatePlain(maxAnglePerSecond / frameRate * shiftToPossibleNegativity(network.getOutput(NeuronName.ROTATE)));
        // adjust weapon
        shootingAngle += SHOOTING_ANGLE_DEFAULT * shiftToPossibleNegativity(network.getOutput(NeuronName.ADJUST));
        // look
        float lookOutput = shiftToPossibleNegativity(network.getOutput(NeuronName.LOOK));
        if (lookOutput > 0)
        {
          LookDirection lookDirection = LookDirection.FORWARD;
          if (lookOutput > LOOK_DIRECTION_RANGE * 4)
            lookDirection = LookDirection.FORWARD_22_45_67_90;
            else if (lookOutput > LOOK_DIRECTION_RANGE * 3)
              lookDirection = LookDirection.FORWARD_22_45_90;
              else if (lookOutput > LOOK_DIRECTION_RANGE * 2)
                lookDirection = LookDirection.FORWARD_22_45;
                else if (lookOutput > LOOK_DIRECTION_RANGE)
                  lookDirection = LookDirection.FORWARD_45;
          HashMap<PVector, Visual> visuals = performLooks(get3dDirection().add(0, shootingAngle, 0), lookDirection);
          
          for (PVector enemyPosition : visuals.keySet())
          {
            if (visuals.get(enemyPosition) != Visual.WALL)
            {
              saveEnemySpotting(visuals.get(enemyPosition), enemyPosition);
            }
          }
        }
        // shoot
        if (network.getOutput(NeuronName.SHOOT) > .5f)
        {
          shoot();
        }
        
        // set inputs
        // set whether the room before the robot is free
        network.setInput(NeuronName.HAPTIC,
          checkMove(getPosition(), getPlainDirection()) ? 1 : 0);
        // set the result of the raycasting: the enemy's type
        network.setInput(NeuronName.VISUAL_TYPE,
          lastEnemySpottedType == Visual.PLAYER ? -1 / getEnemyTimeFactor() :
          lastEnemySpottedType == Visual.ROBOT  ?  1 / getEnemyTimeFactor() : 0);
        // and the enemy's position
        if (lastEnemySpottedType != Visual.WALL)
          network.setInput(NeuronName.VISUAL_POSITION,
            scalarProductFromPosition(lastEnemySpottedPosition) / getEnemyTimeFactor());
        // set the amount of energy which the robot has
        network.setInput(NeuronName.ENERGY, (float) energy / (float) ENERGY_START);
        break;
      case LOOK_FOR_OPPONENTS:
        if (energy > ENERGY_SHOOT * 1.5f)
        {
          HashMap<PVector, Visual> visuals = performLooks(get3dDirection().add(0, shootingAngle, 0),
            LookDirection.FORWARD);
          for (PVector enemyPosition : visuals.keySet())
          {
            if (visuals.get(enemyPosition) != Visual.WALL)
            {
              // remember the spotting
              saveEnemySpotting(visuals.get(enemyPosition), enemyPosition);
              // if the last enemy spotting happened recently, use it
              if (millis() - lastEnemySpottedTime < 1000)
                enemyPosition.mult(2).add(lastEnemySpottedPosition).div(3);
  
              rotateTowardsEnemy(enemyPosition);
              adjustWeaponSystem(lastEnemySpottedType);
              
              shoot();
              break;
            }
          }
        }
        if (millis() - lastEnemySpottedTime < 1000)
        {
          rotateTowardsEnemy(lastEnemySpottedPosition);
          adjustWeaponSystem(lastEnemySpottedType);
          shoot();
          break;
        }
        adjustWeaponSystem(Visual.WALL);
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