class Water{
  PVector position;
  int wavePoints = 20;
  float scale = chunkSize/wavePoints;
  float[][] waves = new float[wavePoints+1][wavePoints+1];
  PShape waterShape = createShape(GROUP);
  
  public Water(PVector position){
     this.position = position;
  }
  
  void display(){
    offset+=0.0001;
    offset=offset%10000000;
    shapeMode(CORNER);
    for(int i = 0; i < wavePoints+1; i++){
      for(int j = 0; j < wavePoints+1; j++){
        waves[i][j] = getHeight((position.x + i*scale)/chunkSize, offset+(position.z + j*scale)/chunkSize);
      }
    }
    
    fill(0, 150, 255, 200);
      
    for(int z = 0; z < wavePoints; z++){
      beginShape(TRIANGLE_STRIP);
      for(int x = 0; x < wavePoints+1; x++){
        vertex(x*scale, waves[x][z], z*scale);
        vertex(x*scale, waves[x][z+1], (z+1)*scale);
      }
      endShape();
    }
  }
  
  float getHeight(float x, float y){
    float noise = noise(x*3, y*3);
    float value = map(noise, 0, 1, -400, 400);
    return value;
  }
  
}
