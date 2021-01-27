import toxi.geom.*;

class Chunk{
  PVector position;
  Vec3D[][] vecs = new Vec3D[vertecies+1][vertecies+1];
  
  float birdsDraw;
  float birdsProbability;
  
  float chunkMin = 1500;
  float chunkMax = -chunkSize;
  
  PShape chunkShape = createShape();
  
  Bird[] flock;
  Water water;
  
  public Chunk(PVector position){
    this.position = position.copy();
    birdsDraw = random(1);
    birdsProbability = 0.7;
    if(birdsDraw>birdsProbability){
      flock = new Bird[20];
      for(int i = 0; i < flock.length; i++){
        flock[i] = new Bird(this);
      }
    }
    
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        float currentHeight = calculateHeight((position.x + x*scale)/(chunkSize*3), (position.z + z*scale)/(chunkSize*3));
        vecs[x][z] = new Vec3D(x*scale, currentHeight, z*scale);
      }
    }
    
    chunkShape.beginShape(QUADS);
    chunkShape.noStroke();
     for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        chunkShape.fill(applyColor(vecs[x][z].y));
        //normal(0, 1, 0);
        chunkShape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z);
        chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        chunkShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z);
        chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        
        //chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        //chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        //chunkShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z);
        
      }
    }
    chunkShape.endShape(CLOSE); 
    
}
  
  int applyColor(float y){
    if(y >= -150){
      return color(214, 175, 15);
    }
    if(y < -150 && y > -4000){
      color c1 = color(145, 145, 145);
      color c2 = color(31, 97, 16);
      return lerpColor(c2, c1, map(y, -150, -4000, 0, 1));
      
    }
    if(y < -4000 && y > -5000){
      color c1 = color(255);
      color c2 = color(145, 145, 145);
      return lerpColor(c1, c2, map(y, -5000, -4000, 0, 1));
    }
    if(y < -5000){
      return color(255);
    }
    return 0;
  }
  
  float calculateHeight(float x, float z){
    float noiseLevel = (float)simplexNoise.noise2(x*2,z*2);
    float detail = map(noiseLevel, -1, 1, 0.3, 7);
    float noiseDetail = noise(x*detail, z*detail);//*3
    float value = map(noiseLevel + 0.7*noiseDetail, -1, 1.5, chunkMin, chunkMax);
    return value;
  }
  
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    shape(chunkShape);
    if(birdsDraw>birdsProbability)displayBirds();
    
    water = new Water(position);
    water.display();
    popMatrix();
    
  }
  
  void displayBirds(){
    for(int i = 0; i < flock.length; i++){
      flock[i].acceleration.set(0, 0, 0);
      flock[i].avoid();
      flock[i].velocity.setMag(10);
      flock[i].alignment(flock);
      flock[i].cohesion(flock);
      flock[i].separation(flock);
      flock[i].display();
    }
  }
  
  PVector getVertex(int x, int y){
    return new PVector(vecs[x][y].x, vecs[x][y].y, vecs[x][y].z);
  }
  
  PVector getPosition(){
    return this.position;
  }
}
