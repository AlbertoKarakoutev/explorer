class Chunk{
 
  float scale = chunkSize/vertecies;
  PVector position;
  color chunkColor;
  float[][] noise = new float[vertecies+1][vertecies+1];
  PShape[] rows = new PShape[vertecies];
  
  PShape chunkShape = createShape(GROUP);
  
  Water water;
  
  public Chunk(PVector position){
    this.position = position.copy();
    water = new Water(position);
    noiseDetail(20);
    noStroke();
    
    for(int z = 0; z < vertecies+1; z++){
      for(int x = 0; x < vertecies+1; x++){
        noise[x][z] = getHeight((position.x + x*scale)/chunkSize, (position.z + z*scale)/chunkSize);
      }
    }
    
    for(int z = 0; z < vertecies; z++){
      PShape row = createShape();
      row.beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < vertecies+1; x++){
        //if(getHeight((position.x + x*scale)/chunkSize, (position.z + z*scale)/chunkSize) < 1000){
        //  fill(0, 0, 255);
        //}else{
        //  fill(0, 255, 0);
        //}
        row.vertex(x*scale, noise[x][z], z*scale);
        row.vertex(x*scale, noise[x][z+1], (z+1)*scale);
      }
      row.endShape(CLOSE);
      chunkShape.addChild(row);
    }
    
  }

 
 float getHeight(float x, float z){
    float noiseLevel = noise(x,z);
    float value = map(noiseLevel, 0, 1, -5000, 5000);
    return value;
  }
  
  void display(){
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x-chunkSize/2, position.y, position.z);
    shape(chunkShape);
    translate(0, 1500, 0);
    water.display();
    popMatrix();
    
  }
  
  PVector getPosition(){
    return this.position;
  }
}
