import toxi.geom.*;

class Chunk{
  
  boolean computed = false;
  
  PVector position;
  PVector[][] vecs = new PVector[vertecies+1][vertecies+1];
  
  float birdsDraw;
  float birdsProbability;
  
  final float CHUNK_MIN = chunkSize/2;
  final float SEA_LEVEL = 0;
  final float SAND_LEVEL = SEA_LEVEL+1000;
  final float SAND_GRASS_LEVEL = -chunkSize/20;
  final float GRASS_LEVEL = -chunkSize/5;
  final float GRASS_ROCK_LEVEL = -chunkSize/3;
  final float ROCK_LEVEL = -chunkSize/2;
  final float CHUNK_MAX = -chunkSize;
  
  TerrainTransition sandToGrass;
  TerrainTransition grassToRock;
  TerrainTransition rockToSnow;
  
  PShape chunkShape = createShape(GROUP);
  
  PShape sandShape = createShape();
  PShape sandGrassShape = createShape();
  PShape grassShape = createShape();
  PShape grassRockShape = createShape();
  PShape rockShape = createShape();
  PShape rockToSnowShape = createShape();
  
  Bird[] flock;
  Cloud cloud;
  
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
    
    cloud = new Cloud(position);
    
    float now = millis();
    //20-30 ms for this segment
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        float currentHeight = calculateHeight((this.position.x + x*scale)/(chunkSize*3), (this.position.z + z*scale)/(chunkSize*3));
        vecs[x][z] = new PVector(x*scale, currentHeight, z*scale);
      }
    }
    
    //40-50 ms for this segment
    sandToGrass = new TerrainTransition(SAND_LEVEL, SAND_GRASS_LEVEL, 10, vecs, sand, grass);
    grassToRock = new TerrainTransition(GRASS_LEVEL, GRASS_ROCK_LEVEL, 5, vecs, grass, rock);
    rockToSnow = new TerrainTransition(ROCK_LEVEL, CHUNK_MAX, 10, vecs, rock, snow);
    sandGrassShape = sandToGrass.getBlendedShape();
    grassRockShape = grassToRock.getBlendedShape();
    rockToSnowShape = rockToSnow.getBlendedShape();
    
    sandShape.setTexture(sand);
    grassShape.setTexture(grass);
    rockShape.setTexture(rock);
    
    textureWrap(REPEAT);
    textureMode(NORMAL);
    //chunkShape.noStroke();
    sandShape.beginShape(QUADS);
    grassShape.beginShape(QUADS);
    rockShape.beginShape(QUADS);
    
    {
    //20-30 ms for this segment
    for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        addSurface(x, z);
      }
    }
    }
    
    sandShape.endShape();
    grassShape.endShape();
    rockShape.endShape();
    
    chunkShape.addChild(sandShape);
    chunkShape.addChild(sandGrassShape);
    chunkShape.addChild(grassShape);
    chunkShape.addChild(grassRockShape);
    chunkShape.addChild(rockShape);
    chunkShape.addChild(rockToSnowShape);
     
    computed = true;
     
    //println(millis()-now);
}

  void addSurface(int x, int z){
    PShape thisShape = null;
    
    PVector n = PVector.sub(vecs[x][z], vecs[x+1][z], null).cross(PVector.sub(vecs[x][z+1], vecs[x+1][z], null));
    n.normalize();
    
    if(vecs[x][z].y >= SAND_LEVEL)thisShape = sandShape;
    if(vecs[x][z].y <= SAND_GRASS_LEVEL && vecs[x][z].y > GRASS_LEVEL)thisShape = grassShape;
    if(vecs[x][z].y <= GRASS_ROCK_LEVEL && vecs[x][z].y > ROCK_LEVEL)thisShape = rockShape;
    
    if(thisShape == null)return;
    
    float textureScale = chunkSize/100;
    
    thisShape.noStroke();
    
    thisShape.normal(n.x, -n.y, n.z);
    
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
    if(y < SAND_GRASS_LEVEL && y > ROCK_LEVEL){
      color c1 = color(255, 255, 255);
      color c2 = color(31, 97, 16);
      return lerpColor(c2, c1, map(y, SAND_LEVEL, ROCK_LEVEL, 0, 1));
      
    }
    if(y < ROCK_LEVEL){
      color c1 = color(255);
      color c2 = color(145, 145, 145);
      return lerpColor(c1, c2, map(y, ROCK_LEVEL, CHUNK_MAX, 0, 1));
    }
    return 0;
  }
  
  
  float calculateHeight(float x, float z){
    float levelNoise = (float)simplexNoise.noise2(x*2,z*2);
    //float levelMultiplier = map(exp(5*(levelNoise-0.9)), 0, 1, 0, 1.2);
    float levelHeight = map(levelNoise, -10, 2, CHUNK_MIN, CHUNK_MAX) * exp(1*(levelNoise-0.9));
    
    float detailNoise = noise(x*25,z*25);
    float detailMultiplier = map(levelNoise, 1/7, 1, 0.1, 1);
    float detailHeight = map(detailNoise, -2, 1, CHUNK_MIN, CHUNK_MAX) * exp(1.5*(levelNoise-0.9));
    
    return (levelHeight + detailHeight)/2;
  }
  
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    shape(chunkShape);
    cloud.display();
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
  
  boolean getComputed(){
    return this.computed;
  }
}
