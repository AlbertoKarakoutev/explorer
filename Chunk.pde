import toxi.geom.*;

class Chunk{
  PVector position;
  Vec3D[][] vecs = new Vec3D[vertecies+1][vertecies+1];
  
  float birdsDraw;
  float birdsProbability;
  
  PShape chunkShape = createShape();
  
  Bird[] flock;
  Water water;
  
  public Chunk(PVector position){
    this.position = position.copy();
    water = new Water(position);
    noiseDetail(40);
    noStroke();
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
        vecs[x][z] = new Vec3D(x*scale, calculateHeight((position.x + x*scale)/(chunkSize*3), (position.z + z*scale)/(chunkSize*3)), z*scale);
        }
    }
    
    chunkShape.beginShape(TRIANGLES);
     for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        if(vecs[x][z].y < -2500){
          chunkShape.fill(200);
        }else if(vecs[x][z].y < -150){
          chunkShape.fill(color(31, 97, 16));
        }else{
          chunkShape.fill(color(214, 175, 15));
        }
        chunkShape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z);
        chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        chunkShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z);
        chunkShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z);
        chunkShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z);
        
      }
    }
    chunkShape.endShape(CLOSE);
  }
  
  
  float calculateHeight(float x, float z){
    float noiseLevel = (float)simplexNoise.noise2(x*2,z*2);
    float noiseDetail = noise(x*3,z*3);
    float noiseMicro = noise(x*7, z*7);
    float value = map(noiseLevel + 0.7*noiseDetail + 2*noiseMicro, 0, 4.2, 1000, (-0.75)*chunkSize);
    return value;
  }
  
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    shape(chunkShape);
    if(birdsDraw>birdsProbability)displayBirds();
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
