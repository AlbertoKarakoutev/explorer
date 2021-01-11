class Chunk{
 
  int vertecies = 200;
  float scale = chunkSize/vertecies;
  PVector position;
  color chunkColor;
  float[][] noise = new float[vertecies+1][vertecies+1];
  PShape[] rows = new PShape[vertecies];
  
  PShape chunkShape = createShape(GROUP);
  
  public Chunk(PVector position){
    this.position = position.copy();
    noiseDetail(20);
    noStroke();
    for(int z = 0; z < vertecies; z++){
      PShape row = createShape();
      row.beginShape(QUAD_STRIP);
      for(int x = 0; x < vertecies+1; x++){
        row.vertex(x*scale, getHeight((position.x + x*scale)/chunkSize, (position.z + z*scale)/chunkSize), z*scale);
        row.vertex(x*scale, getHeight((position.x + x*scale)/chunkSize, (position.z + (z+1)*scale)/chunkSize), (z+1)*scale);
      }
      row.endShape(CLOSE);
      chunkShape.addChild(row);
    }
  }

 
 float getHeight(float x, float z){
    float noise = noise(x, z);
    //float noise = random(0.4, 0.6);
    float value = map(noise, 0, 1, 0, 2000);
    return value;
  }
  
  void display(){
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x-chunkSize/2, position.y, position.z);
    shape(chunkShape);
    popMatrix();
    
  }
  
  PShape getChunkShape(){
    return this.chunkShape;
  }
  
  PVector getPosition(){
    return this.position;
  }
}
