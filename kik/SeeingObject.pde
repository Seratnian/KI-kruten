interface SeeingObject
{
  void performLook(PVector angle, HashMap<PVector, Visual> out);
  HashMap<PVector, Visual> performLooks(ArrayList<PVector> directions);
  HashMap<PVector, Visual> performLooks(PVector baseDirection, LookDirection lookDirection);
}

public enum Visual
{
  NOTHING, WALL, ROBOT, PLAYER
}

public enum LookDirection
{
  FORWARD, FORWARD_AND_45, FORWARD_22_AND_45, FORWARD_45_AND_90, FORWARD_22_45_AND_90, FORWARD_22_45_67_AND_90
}