class Chunk{
 
  float scale = chunkSize/vertecies;
  PVector position;
  color chunkColor;
  PVector[][] noise = new PVector[vertecies+1][vertecies+1];
  PShape[] rows = new PShape[vertecies];
  
  PShape chunkShape = createShape(GROUP);
  PImage grass;
  
  Water water;
  
  public Chunk(PVector position){
    this.position = position.copy();
    grass = loadImage("grass.jpeg");
    water = new Water(position);
    noiseDetail(20);
    noStroke();
    
    for(int z = 0; z < vertecies+1; z++){
      for(int x = 0; x < vertecies+1; x++){
        noise[x][z] = new PVector(x*scale, getHeight((position.x + x*scale)/chunkSize, (position.z + z*scale)/chunkSize), z*scale);
      }
    }
    
    for(int z = 0; z < vertecies; z++){
      PShape row = createShape();
      
      for(int x = 0; x < vertecies; x++){
        
        if(noise[x][z].y < -2000){
          fill(200);
        }else{
          fill(78, 99, 12);
        }
        PShape triangle = createShape();
        triangle.beginShape(TRIANGLES);
          triangle.vertex(noise[x][z].x, noise[x][z].y, noise[x][z].z, 0, 0);
          triangle.vertex(noise[x][z+1].x, noise[x][z+1].y, noise[x][z+1].z, 0, 0);
          triangle.vertex(noise[x+1][z].x, noise[x+1][z].y, noise[x+1][z].z, 0, 0);
          
          triangle.vertex(noise[x+1][z].x, noise[x+1][z].y, noise[x+1][z].z, 0, 0);
          triangle.vertex(noise[x+1][z+1].x, noise[x+1][z+1].y, noise[x+1][z+1].z, 0, 0);
          triangle.vertex(noise[x][z+1].x, noise[x][z+1].y, noise[x][z+1].z, 0, 0);
        triangle.endShape();
        chunkShape.addChild(triangle);
      }
    }
  }

 
 float getHeight(float x, float z){
    float noiseLevel = noise(x*3,z*3);
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
