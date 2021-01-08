class Chunk{
 
  PVector position;
  float size;
  color chunkColor;
  int vertecies = 35;
  float scale;
  float[] chunk;
  float[][] noise = new float[vertecies+1][vertecies+1];
  PImage grass;
  
  public Chunk(PVector position, float size, color c, float[] chunk, PImage grass){
    this.position = position.copy();
    this.size = size;
    this.scale = size/vertecies;
    this.chunk = chunk;
    this.grass = grass;
    chunkColor = c;
  }

  float getHeight(float x, float y){
    float noise = noise(x*3, y*3);
    float value = map(noise, 0, 1, 0, 10000);
    return value;
  }
  
  void display(){
    shapeMode(CENTER);
    pushMatrix();
    translate(position.x, 0, position.z);
    for(int y = 0; y < vertecies; y++){
      beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < vertecies+1; x++){
        
        
        if(getHeight((position.x + x*scale)/size, (position.z + y*scale)/size) < 3000)fill(255);
        if(getHeight((position.x + x*scale)/size, (position.z + y*scale)/size) > 3000)fill(chunkColor);
        if(getHeight((position.x + x*scale)/size, (position.z + y*scale)/size) > 6000)fill(0, 0, 190);
        //text(position.x + " " + position.z, position.x+size/2, 0, position.z+size/2);
        textSize(20);
        vertex(x*scale, getHeight((position.x + x*scale)/size, (position.z + y*scale)/size), y*scale);
        vertex(x*scale, getHeight((position.x + x*scale)/size, (position.z + (y+1)*scale)/size), (y+1)*scale);
      }
      endShape();
    }
    //box(size, 20, size);
    popMatrix();
  }
  
  PVector getPosition(){
    return this.position;
  }
}
