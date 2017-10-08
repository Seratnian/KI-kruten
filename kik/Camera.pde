class Camera
{
  private final PVector eye = new PVector(0, LEVEL_UNIT, 0);
  private final PVector center = new PVector(0, 0, LEVEL_UNIT);
  private final PVector up = new PVector(0, -1, 0);
  
  static final int EYEX = 0;
  static final int EYEY = 1;
  static final int EYEZ = 2;
  static final int CENTERX = 3;
  static final int CENTERY = 4;
  static final int CENTERZ = 5;
  static final int UPX = 6;
  static final int UPY = 7;
  static final int UPZ = 8;
  
  PVector getEye() { return eye; }
  PVector getCenter() { return center.copy().add(eye); }
  PVector getUp() { return up; }
  
  float getEyeX() { return eye.x; }
  float getEyeY() { return eye.y; }
  float getEyeZ() { return eye.z; }
  float getCenterX() { return center.x + eye.x; }
  float getCenterY() { return center.y + eye.y; }
  float getCenterZ() { return center.z + eye.z; }
  float getUpX() { return up.x; }
  float getUpY() { return up.y; }
  float getUpZ() { return up.z; }
  
  PVector getDirection() { return center; }
  PVector getPlainDirection()
  {
    return new PVector(center.x, center.z).normalize();
  }
  
  void movePlain(PVector dir)
  {
    camera.add(dir.x, Camera.EYEX);
    camera.add(dir.y, Camera.EYEZ);
  }
  
  void rotate(PVector rotation)
  {
    //rotate horizontally 
    PVector xz = new PVector(center.x, center.z);
    xz.rotate(rotation.x);
    center.x = xz.x;
    center.z = xz.y;
    
    //rotate vertically
    center.y -= rotation.y;
    center.normalize();
  }
  
  float add(float what, int whereTo)
  {
    switch (whereTo)
    {
      case EYEX:
        eye.x += what;
        return eye.x;
      case EYEY:
        eye.y += what;
        return eye.y;
      case EYEZ:
        eye.z += what;
        return eye.z;
      case CENTERX:
        center.x += what;
        return center.x;
      case CENTERY:
        center.y += what;
        return center.y;
      case CENTERZ:
        center.z += what;
        return center.z;
      case UPX:
        up.x += what;
        return up.x;
      case UPY:
        up.y += what;
        return up.y;
      case UPZ:
        up.z += what;
        return up.z;
      default:
          return 0;
    }
  }
  float sub(float what, int whereFrom)
  {
    return add(-what, whereFrom);
  }
  
  String toString()
  {
    return getEyeX() + " " + getEyeY() + " " + getEyeZ() + "\n" +
    getCenterX() + " " + getCenterY() + " " + getCenterZ() + "\n" +
    getUpX() + " " + getUpY() + " " + getUpZ() + "\n";
  }
  
}