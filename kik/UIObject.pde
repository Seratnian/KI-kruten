class UIObject extends SteadyObject
{
  int type = 0;
  static final int TYPE_DEFAULT = 0;
  static final int TYPE_IMAGE = 1;
  static final int TYPE_TEXT = 2;
  PImage image;
  String text;
  int removeTime;
  PVector originalPosition;
  static final int LIFETIME = 3000; 
  int updateMethod = 0;
  static final int METHOD_DEFAULT = 0;
  static final int METHOD_FPS = 1;
  static final int METHOD_DIE = 2;
  
  UIObject(PVector position, float scale, PVector rotations, PShape structure, color plainColor)
  {
    super(position, scale, rotations, structure, plainColor);
  }
  UIObject(PVector position, float scale, PVector rotations, PShape structure, PImage texture)
  {
    super(position, scale, rotations, structure, texture);
  }
  UIObject(PVector position, float scale, PVector rotations, PImage image)
  {
    super(position, scale, rotations);
    this.image = image;
    type = TYPE_IMAGE;
  }
  UIObject(PVector position, float scale, PVector rotations, String text)
  {
    super(position, scale, rotations);
    this.text = text;
    type = TYPE_TEXT;
  }
  UIObject(PVector position, float scale, PVector rotations, int updateMethod)
  {
    super(position, scale, rotations);
    this.updateMethod = updateMethod;
    switch (updateMethod)
    {
      case METHOD_DEFAULT:
      default:
        break;
      case METHOD_FPS:
        type = TYPE_TEXT;
        break;
      case METHOD_DIE:
        removeTime = millis() + LIFETIME;
        break;
    }
  }
  UIObject(PVector position, float scale, PVector rotations, int updateMethod, String text)
  {
    this(position, scale, rotations, updateMethod);
    this.text = text;
    originalPosition = position.copy();
    type = TYPE_TEXT;
  }
  
  void display()
  {
    switch (type)
    {
      case TYPE_DEFAULT:
      default:
        super.display();
        break;
      case TYPE_IMAGE:
        image(image, getPosition().x, getPosition().y);
        break;
      case TYPE_TEXT:
        text(text, getPosition().x, getPosition().y);
        break;
    }
  }
  
  boolean update()
  {
    switch (updateMethod)
    {
      case METHOD_DEFAULT:
      default:
        break;
      case METHOD_FPS:
        text = "FPS: " + frameRate;
        break;
      case METHOD_DIE:
        getPosition().y = originalPosition.y - messages_destroyed * LINE_HEIGHT;
        if (millis() > removeTime) return false;
        break;
    }
    return super.update();
  }
}