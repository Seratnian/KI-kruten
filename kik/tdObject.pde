/**
 * Define available methods for every 3D-Object.
 * @author sschleie@hs-mittweida.de, ritter@hs-mittweida.de
 * 
 * Copyright Professorship Media Informatics, University of Applied Sciences Mittweida, Germany.
 */

interface tdObject
{
  
  /** Reset basic values */
  void reset(PVector position, PVector rotations, PShape structure, color fillColor);
  
  /** Show on screen */
  void display();

  /** Update model parameters */
  void update();
  
  /** Checks viewing properties */
  boolean check();

  /** Function logic to check and update model and view */
  boolean script();
  
  /** Returns the object containing the current position */
  PVector getPos();
  
  /** Returns the graphical structure of the object */
  ArrayList<PShape> getStr();
  
}