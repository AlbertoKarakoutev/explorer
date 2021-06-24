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
  
  final float density = 1;

  TerrainTransition sandToGrass;
  TerrainTransition grassToRock;
  TerrainTransition rockToSnow;
  
  PShape chunkShape = createShape(GROUP);
  
  PShape sandShape = createShape();
  PShape sandGrassShape = createShape();
  PShape grassShape = createShape();
  PShape grassRockShape = createShape();
  PShape rockShape = createShape();
  PShape rockSnowShape = createShape();
  
  Bird[] flock;
  
  public Chunk(){}

  public Chunk(PVector position){
    this.position = position.copy();
    
    initializeBirds();
    initializeVectors();

    textureWrap(REPEAT);
    textureMode(NORMAL);
    
    initializeTransitionShapes();
    initializeSolidShapes();
    
  }

  void updateShapeAtCoordinates(int x, int z){
    PShape thisShape = null;
    
    if(vecs[x][z].y >= SAND_LEVEL)thisShape = sandShape;
    if(vecs[x][z].y <= SAND_GRASS_LEVEL && vecs[x][z].y > GRASS_LEVEL)thisShape = grassShape;
    if(vecs[x][z].y <= GRASS_ROCK_LEVEL && vecs[x][z].y > ROCK_LEVEL)thisShape = rockShape;
    
    if(thisShape == null)return;
    
    addSurfaceToShape(thisShape, vecs, x, z);
  } 
  void addSurfaceToShape(PShape shape, PVector[][] vecs, int x, int z){
    PVector n = PVector.sub(vecs[x][z], vecs[x+1][z], null).cross(PVector.sub(vecs[x][z+1], vecs[x+1][z], null));
    n.normalize();
    n.y += 1;
    n.normalize();
    
    float textureScale = chunkSize/100;
    
    shape.noStroke();
    shape.normal(n.x, -n.y, n.z);

    shape.vertex(vecs[x][z].x, vecs[x][z].y, vecs[x][z].z, (x*scale)/textureScale, (z*scale)/textureScale);
    shape.vertex(vecs[x+1][z].x, vecs[x+1][z].y, vecs[x+1][z].z, ((x+1)*scale)/textureScale, (z*scale)/textureScale);
    shape.vertex(vecs[x+1][z+1].x, vecs[x+1][z+1].y, vecs[x+1][z+1].z, ((x+1)*scale)/textureScale, ((z+1)*scale)/textureScale);
    shape.vertex(vecs[x][z+1].x, vecs[x][z+1].y, vecs[x][z+1].z, (x*scale)/textureScale, ((z+1)*scale)/textureScale);
    
  }

  float calculateRoughHeightAtLocation(float xInitial, float zInitial){
    float x = (this.position.x + xInitial*scale)/(chunkSize*3);
    float z = (this.position.z + zInitial*scale)/(chunkSize*3);
    
    float levelNoise = (float)simplexNoise.noise2(x*2,z*2);
    float levelHeight = map(levelNoise, lowestPoint, 2, CHUNK_MIN, CHUNK_MAX) * exp(1*(levelNoise-0.9));
    
    float detailNoise = noise(x*25,z*25);
    float detailHeight = map(detailNoise, -2, 1, CHUNK_MIN, CHUNK_MAX) * exp(1.5*(levelNoise-0.9));

    return (levelHeight + detailHeight)/2;
  }
  
  float calculateSmoothHeightAtLocation(float xInitial, float zInitial){
    float x = (this.position.x + xInitial*scale)/(chunkSize*3);
    float z = (this.position.z + zInitial*scale)/(chunkSize*3);
    
    float levelNoise = (float)simplexNoise.noise2(x*2,z*2);
    float levelHeight = map(levelNoise, lowestPoint, 2, CHUNK_MIN, CHUNK_MAX) * exp(1*(levelNoise-0.9));

    return levelHeight;
  }
   
  void display(){
    shapeMode(CORNER);
    push();
    translate(position.x, position.y, position.z);
    pushStyle();
    ambient(255, 255, 255);
    shape(chunkShape);
    popStyle();
    if(areBirdsVisible && birdsSpawnPercentage>birdsSpawnPercentageMinimum)displayBirds();  
    pop();    
  }
  void displayBirds(){
    if(flock != null){
      for(int i = 0; i < flock.length; i++){
        flock[i].acceleration.set(0, 0, 0);
        flock[i].avoidCollisions();
        flock[i].velocity.setMag(10);
        flock[i].alignment(flock);
        flock[i].cohesion(flock);
        flock[i].separation(flock);
        flock[i].display();
      }
    }
  }
  

  void initializeVectors(){    
    for(int z = 0; z <= vertecies; z++){
      for(int x = 0; x <= vertecies; x++){
        float vecHeight = (areDetailsVisible) ? calculateRoughHeightAtLocation(x, z) : calculateSmoothHeightAtLocation(x, z);
        vecs[x][z] = new PVector(x*scale, vecHeight, z*scale);
        //vecs[x][z] = new PVector(x*scale, 0, z*scale);
      }
    }
  }
  void initializeBirds(){
    birdsSpawnPercentage = random(1);
    birdsSpawnPercentageMinimum = 0.3;
    if(birdsSpawnPercentage>birdsSpawnPercentageMinimum && areBirdsVisible){
      flock = new Bird[80];
      for(int i = 0; i < flock.length; i++){
        flock[i] = new Bird(this);
      }
    }
  }
  void initializeTransitionShapes(){    
    
    sandToGrass = new TerrainTransition(SAND_LEVEL, SAND_GRASS_LEVEL, 10, vecs, sand, grass);
    grassToRock = new TerrainTransition(GRASS_LEVEL, GRASS_ROCK_LEVEL, 5, vecs, grass, rock);
    rockToSnow = new TerrainTransition(ROCK_LEVEL, CHUNK_MAX, 15, vecs, rock, snow);
    
    sandGrassShape = sandToGrass.getBlendedShape();
    grassRockShape = grassToRock.getBlendedShape();
    rockSnowShape = rockToSnow.getBlendedShape();

    chunkShape.addChild(sandGrassShape);
    chunkShape.addChild(grassRockShape);
    chunkShape.addChild(rockSnowShape);
    
  }
  void initializeSolidShapes(){
  
    sandShape.setTexture(sand);
    grassShape.setTexture(grass);
    rockShape.setTexture(rock);
    
    sandShape.beginShape(QUADS);
    grassShape.beginShape(QUADS);
    rockShape.beginShape(QUADS);
    
    for(int z = 0; z < vertecies; z++){
      for(int x = 0; x < vertecies; x++){
        updateShapeAtCoordinates(x, z);
      }
    }
    
    sandShape.endShape(CLOSE);
    grassShape.endShape(CLOSE);
    rockShape.endShape(CLOSE);
    
    chunkShape.addChild(sandShape);
    chunkShape.addChild(grassShape);
    chunkShape.addChild(rockShape);
  }


  PVector getVertex(int x, int y){
    return new PVector(vecs[x][y].x, vecs[x][y].y, vecs[x][y].z);
  }
  
  PVector getPosition(){
    return this.position;
  }
  
  float getDensity(){
    return this.density;
  }

  PShape getShape(){
    return this.chunkShape;
  }

}
