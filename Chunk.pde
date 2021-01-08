class Chunk{
 
  PVector position;
  float size;
  color chunkColor;
  int vertecies = 300;
  float scale;
  float[] chunk;
  float[][] noise = new float[vertecies+1][vertecies+1];
  PImage grass;
  PShape chunkShape = createShape(GROUP);
  boolean initialized;
  
  public Chunk(PVector position, float size, color c, float[] chunk, PImage grass){
    this.position = position.copy();
    this.size = size;
    this.scale = size/vertecies;
    this.chunk = chunk;
    this.grass = grass;
    chunkColor = c;
    
    float noiseDetail = (chunk[0] + chunk[1])*(chunk[0] + chunk[1] + 1)/2 + chunk[1];
    noiseDetail = 5;
    noiseDetail((int)noiseDetail);
    
    for(int z = 0; z < vertecies+1; z++){
      for(int x = 0; x < vertecies+1; x++){
        noise[x][z] = getHeight((position.x + x*scale)/size, (position.z + z*scale)/size);
      }
    }
    
    for(int z = 0; z < vertecies; z++){
      PShape triangle = createShape();
      triangle.beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < vertecies+1; x++){
        
        //if(noise[x][z] < -0)fill(255);
        //if(noise[x][z] > -7000)fill(chunkColor);
        //if(noise[x][z] > 2000)fill(0, 0, 190);
        
        triangle.vertex(x*scale, noise[x][z], z*scale);
        triangle.vertex(x*scale, noise[x][z+1], (z+1)*scale);
      }
      triangle.endShape();
      chunkShape.addChild(triangle);
    }
    //box(size, 20, size);
  }

  float getHeight(float x, float z){
    float noise = noise(x*2, z*2);
    float value = map(noise, 0, 1, 0, -5000);
    return value;
  }
  
  void display(){
    
    pushMatrix();
    translate(position.x, 5000, position.z);
    shape(chunkShape);
    popMatrix();
    
  }
  
  PVector getPosition(){
    return this.position;
  }
}
