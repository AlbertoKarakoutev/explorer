class Water{
  PVector position;
  
  int wavePoints = 90;
  float waveScale = (chunkSize*5)/wavePoints;
  float[][] waves = new float[wavePoints+1][wavePoints+1];
  
  public Water(PVector position){
     this.position = position;
  }
  
  
  void display(){

    calculateWaveVectors();

    push();

      translate(position.x, position.y, position.z);

      addStyle();
      addVertecies();

    pop();  
  }

  void addStyle(){
    textureWrap(REPEAT);
    textureMode(NORMAL);
    tint(0, 130, 255, 200);
    shininess(20);
    specular(1, 1, 1);
  }

  void addVertecies(){
    for(int z = 0; z < waves.length-1; z++){
      PShape row = createShape();
      beginShape(QUADS);
      
      texture(sea);
      for(int x = 0; x < waves[z].length-1; x++){
        vertex(x*waveScale,     waves[x][z],     z*waveScale,     0.1, 0.1);
        vertex(x*waveScale,     waves[x][z+1],   (z+1)*waveScale, 0.1, 0.9);
        vertex((x+1)*waveScale, waves[x+1][z+1], (z+1)*waveScale, 0.9, 0.9);
        vertex((x+1)*waveScale, waves[x+1][z],   z*waveScale,     0.9, 0.1);
      }

      endShape();
    }
  }

  void calculateWaveVectors(){
    offset+=0.001;
    offset=offset%10000000;
    shapeMode(CORNER);
    for(int i = 0; i < waves.length; i++){
      for(int j = 0; j < waves[i].length; j++){
        waves[i][j] = getHeight((position.x + i*scale)/chunkSize, offset+(position.z + j*scale)/chunkSize);
      }
    }
  }

  
  float getHeight(float x, float y){
    float noise = noise(x*6, y*6);
    float value = map(noise, 0, 1, 0, -600);
    return value;
  }
  
}
