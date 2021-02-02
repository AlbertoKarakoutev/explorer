class Water{
  PVector position;
  
  int wavePoints = 90;
  float scale = (chunkSize*3)/wavePoints;
  float[][] waves = new float[wavePoints+1][wavePoints+1];
  
  public Water(PVector position){
     this.position = position;
  }
  
  
  void display(){
    offset+=0.001;
    offset=offset%10000000;
    shapeMode(CORNER);
    for(int i = 0; i < waves.length; i++){
      for(int j = 0; j < waves[i].length; j++){
        waves[i][j] = getHeight((position.x + i*scale)/chunkSize, offset+(position.z + j*scale)/chunkSize);
      }
    }
    pushMatrix();
    translate(position.x, position.y, position.z);
    pushStyle();
    textureWrap(REPEAT);
    textureMode(NORMAL);
    tint(0, 130, 255, 150);
    shininess(20);
    specular(1, 1, 1);
    for(int z = 0; z < waves.length-1; z++){
      PShape row = createShape();
      beginShape(TRIANGLES);
      
      texture(sea);
      for(int x = 0; x < waves[z].length-1; x++){
        vertex(x*this.scale, waves[x][z], z*this.scale, 0, 0);
        vertex(x*this.scale, waves[x][z+1], (z+1)*this.scale, 0, 1);
        vertex((x+1)*this.scale, waves[x+1][z], z*this.scale, 1, 1);
        
        vertex(x*this.scale, waves[x][z+1], (z+1)*this.scale, 0, 1);
        vertex((x+1)*this.scale, waves[x+1][z+1], (z+1)*this.scale, 1, 1);
        vertex((x+1)*this.scale, waves[x+1][z], z*this.scale, 1, 0);
      }
      endShape();
    }
    popStyle();
    popMatrix();  
  }
  
  float getHeight(float x, float y){
    float noise = noise(x*6, y*6);
    float value = map(noise, 0, 1, 0, -600);
    return value;
  }
  
}
