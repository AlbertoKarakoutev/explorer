class Chunk{
  
  PVector position;
  PVector[][] vecs = new PVector[vertecies+1][vertecies+1];
  
  float birdsSpawnPercentage;
  float birdsSpawnPercentageMinimum;
  
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
    birdsSpawnPercentage = random(1);
    birdsSpawnPercentageMinimum = 0;
    if(birdsSpawnPercentage>birdsSpawnPercentageMinimum){
      flock = new Bird[40];
      for(int i = 0; i < flock.length; i++){
        flock[i] = new Bird(this);
      }
    }
    
    //cloud = new Cloud(position);
    
    float now = millis();
    //20-30 ms for this segment
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        vecs[x][z] = new PVector(x*scale, calculateHeight(x, z), z*scale);
      }
    }
    
    
    sandToGrass = new TerrainTransition(SAND_LEVEL, SAND_GRASS_LEVEL, 10, vecs, sand, grass);
    grassToRock = new TerrainTransition(GRASS_LEVEL, GRASS_ROCK_LEVEL, 5, vecs, grass, rock);
    rockToSnow = new TerrainTransition(ROCK_LEVEL, CHUNK_MAX, 15, vecs, rock, snow);
    
    //40-50 ms for this segment
    sandGrassShape = sandToGrass.getBlendedShape();
    grassRockShape = grassToRock.getBlendedShape();
    rockToSnowShape = rockToSnow.getBlendedShape();
    
    sandShape.setTexture(sand);
    grassShape.setTexture(grass);
    rockShape.setTexture(rock);
    
    textureWrap(REPEAT);
    textureMode(NORMAL);
    
    sandShape.beginShape(QUADS);
    grassShape.beginShape(QUADS);
    rockShape.beginShape(QUADS);
    
  
    //20-30 ms for this segment
    for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        addSurface(x, z);
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
  
  float calculateHeight(float xInitial, float zInitial){
    float x = (this.position.x + xInitial*scale)/(chunkSize*3);
    float z = (this.position.z + zInitial*scale)/(chunkSize*3);
    
    float levelNoise = (float)simplexNoise.noise2(x*2,z*2);
    //float levelMultiplier = map(exp(5*(levelNoise-0.9)), 0, 1, 0, 1.2);
    float levelHeight = map(levelNoise, -10, 2, CHUNK_MIN, CHUNK_MAX) * exp(1*(levelNoise-0.9));
    
    float detailNoise = noise(x*25,z*25);
    //float detailMultiplier = map(levelNoise, 1/7, 1, 0.1, 1);
    float detailHeight = map(detailNoise, -2, 1, CHUNK_MIN, CHUNK_MAX) * exp(1.5*(levelNoise-0.9));
    
    return (levelHeight + detailHeight)/2;
  }
  
  
  void display(){
    //Goal is < 0.02s
    shapeMode(CORNER);
    pushMatrix();
    translate(position.x, position.y, position.z);
    pushStyle();
    ambient(255, 255, 255);
    shape(chunkShape);
    popStyle();
    //cloud.display();
    if(birdsSpawnPercentage>birdsSpawnPercentageMinimum)displayBirds();  
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
