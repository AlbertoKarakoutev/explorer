import toxi.geom.*;

class Chunk{
  PVector position;
  PVector[][] vecs = new PVector[vertecies+1][vertecies+1];
  
  float birdsDraw;
  float birdsProbability;
  
  final float CHUNK_MIN = chunkSize/4;
  final float SEA_LEVEL = 0;
  final float SAND_LEVEL = -chunkSize/20;
  final float MOUNTAIN_ROCKS = -chunkSize/1.4;
  final float CHUNK_MAX = -chunkSize;
  
  PShape chunkShape = createShape(GROUP);
  
  PShape sandShape = createShape();
  PShape grassShape = createShape();
  PShape rockShape = createShape();
  Bird[] flock;
  
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
        float currentHeight = calculateHeight((this.position.x + x*scale)/(chunkSize*3), (this.position.z + z*scale)/(chunkSize*3));
        vecs[x][z] = new PVector(x*scale, currentHeight, z*scale);
      }
    }
    
    sandShape.setTexture(sand);
    grassShape.setTexture(grass);
    rockShape.setTexture(rock);
    
    textureWrap(REPEAT);
    textureMode(NORMAL);
    //chunkShape.noStroke();
    sandShape.beginShape(QUADS);
    grassShape.beginShape(QUADS);
    rockShape.beginShape(QUADS);
     for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        //chunkShape.fill(applyColor(vecs[x][z].y));
        
        addSurface(x, z);
        
      }
    }
    sandShape.endShape();
    grassShape.endShape();
    rockShape.endShape();
    
    chunkShape.addChild(sandShape);
    chunkShape.addChild(grassShape);
    chunkShape.addChild(rockShape);
    
}

  void addSurface(int x, int z){
    PShape thisShape = null;
    
    //PVector thisVector = vecs[x][z];
    
    PVector n = PVector.sub(vecs[x][z], vecs[x+1][z], null).cross(PVector.sub(vecs[x][z+1], vecs[x+1][z], null));
    n.normalize();
    
    if(vecs[x][z].y >= SAND_LEVEL)thisShape = sandShape;
    if(vecs[x][z].y < SAND_LEVEL)thisShape = grassShape;
    if(vecs[x][z].y < MOUNTAIN_ROCKS)thisShape = rockShape;
    
    float textureScale = chunkSize/30;
    
    thisShape.noStroke();
    
    thisShape.normal(n.x, -1, n.z);
    
    thisShape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z, (x*scale)/textureScale, (z*scale)/textureScale);
    thisShape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z, ((x+1)*scale)/textureScale, (z*scale)/textureScale);
    thisShape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z, ((x+1)*scale)/textureScale, ((z+1)*scale)/textureScale);
    thisShape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z, (x*scale)/textureScale, ((z+1)*scale)/textureScale);
    
  }

  int applyColor(float y){
    if(y >= SEA_LEVEL){
      return color(214, 175, 15);
    }
    if(y < SEA_LEVEL && y > SAND_LEVEL){
      color c1 = color(214, 175, 15);
      color c2 = color(31, 97, 16);
      return lerpColor(c1, c2, map(y, SEA_LEVEL, SAND_LEVEL, 0, 1));
      
    }
    if(y < SAND_LEVEL && y > MOUNTAIN_ROCKS){
      color c1 = color(255, 255, 255);
      color c2 = color(31, 97, 16);
      return lerpColor(c2, c1, map(y, SAND_LEVEL, MOUNTAIN_ROCKS, 0, 1));
      
    }
    if(y < MOUNTAIN_ROCKS){
      color c1 = color(255);
      color c2 = color(145, 145, 145);
      return lerpColor(c1, c2, map(y, MOUNTAIN_ROCKS, CHUNK_MAX, 0, 1));
    }
    return 0;
  }
  
  
  float calculateHeight(float x, float z){
    float noiseLevel = (float)simplexNoise.noise2(x*2,z*2);
    float noiseDetail = noise(x*25,z*25);//*3
    float detailMultiplier = (noiseLevel<=-0.5) ? 0.1 : map(noiseLevel, -0.5, 1, 0.1, 1);
    float heightMultiplier = map(noiseLevel, -1, 1, 0, 1.2);
    float value = map(noiseLevel + noiseDetail*detailMultiplier, -1, 2, CHUNK_MIN, CHUNK_MAX) * heightMultiplier;
    return value;
  }
  
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    shape(chunkShape);
    if(birdsDraw>birdsProbability)displayBirds();  
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
