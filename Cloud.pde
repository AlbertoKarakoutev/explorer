class Cloud{
  PVector position;
  PShape cloudShape;
  
  public Cloud(PVector position){
   this.position = position; 
   cloudShape = createShape(BOX, chunkSize*3, 2000, chunkSize*3);
   noStroke();
   cloudShape.setFill(color(100, 100, 100, 200));
  }
  
  void display(){
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, -chunkSize/1.3, position.z);
    shape(cloudShape);
    popMatrix();
  }
  
}
