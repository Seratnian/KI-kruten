class SteadyObject
{
  final private PVector position = new PVector();
  final private PVector rotations = new PVector();
  private float scale;
  color plainColor;
  PShape structure;
  
  SteadyObject(PVector position, float scale, PVector rotations, PShape structure, color plainColor)
  {
    init(position, scale, rotations);
    setStructure(structure);
    this.plainColor = plainColor;
    structure.setFill(plainColor);
  }
  
  SteadyObject(PVector position, float scale, PVector rotations, PShape structure, PImage texture)
  {
    init(position, scale, rotations);
    setStructure(structure);
    structure.setTexture(texture);
  }
  
  SteadyObject(PVector position, float scale, PVector rotations, PShape structure)
  {
    init(position, scale, rotations);
    setStructure(structure);
  }
  
  SteadyObject(PVector position, float scale, PVector rotations)
  {
    init(position, scale, rotations);
  }
  
  void init(PVector position, float scale, PVector rotations)
  {
    this.position.set(position);
    this.rotations.set(rotations);
    this.scale = scale;
  }
  
  PVector getPosition() { return position; }
  PVector getRotations() { return rotations; }
  float getScale() { return scale; }
  PShape getStructure() { return structure; }
  
  void setStructure(PShape structure)
  {
    this.structure = structure;
    refreshStructure();
  }
  
  void refreshStructure()
  {
    structure.resetMatrix();
    // set rotation
    structure.rotateX(rotations.x);
    structure.rotateY(rotations.y);
    structure.rotateZ(rotations.z);
    // set scale
    //structure.scale(scale);
    // set position
    structure.translate(position.x, position.y, position.z);
    // set color
    structure.setTextureMode(REPEAT);
    structure.setStroke(0);
  }
  
  void display()
  {
    shape(structure);
  }
  
  void drawLine(PVector start, PVector end)
  {
    line(start.x, start.y, start.z, end.x, end.y, end.z);
  }

  boolean update()
  {
    return true;
  }
  
  boolean check()
  {
    return true;
  }

  boolean script()
  {
    return true;
  }
  
}