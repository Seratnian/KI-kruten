class Projectile extends MoveableObject
{
  boolean shouldBeDestroyed = false;
  int damage = 1;

  Projectile(PVector position, PVector rotations, PShape structure, float size, color plainColor, float speed)
  {
    super(position, 1, rotations, structure, size, plainColor);
    this.speed = speed;
  }

  boolean update()
  {
    // check if projectile is outside the level
    PVector position = getPosition();
    shouldBeDestroyed = position.x < -LEVEL_WIDTH/2  - LEVEL_UNIT  || position.x > LEVEL_WIDTH/2  + LEVEL_UNIT || 
                        position.z < -LEVEL_WIDTH/2  - LEVEL_UNIT  || position.z > LEVEL_WIDTH/2  + LEVEL_UNIT ||
                        position.y < -LEVEL_HEIGHT/2 - LEVEL_UNIT || position.y > LEVEL_HEIGHT/2 + LEVEL_UNIT;
    // check if projectile collides with wall
    shouldBeDestroyed = !checkMove(getPosition(), new PVector(1, 0, 0), false) && shouldBeDestroyed;
    if (!shouldBeDestroyed)
    {
      //message(getMoveDirection3d().toString());
      move3d(getMoveDirection3d());
      for (MoveableObject mo : enemies)
      {
        if (checkCollision(mo))
        {
          mo.doDamage(damage);
          shouldBeDestroyed = true;
        }
      }
      if (checkCollision(player))
      {
        message("You were hit. Damage: " + damage);
      }
    }
    return !shouldBeDestroyed;
  }
}